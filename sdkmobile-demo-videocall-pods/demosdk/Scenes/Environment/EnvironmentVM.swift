//
//  EnvironmentVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 15/6/22.
//

import core
import sdk
import Foundation

protocol EnvironmentVMInput {
    func getConfigurationData()
    func setConfigurationData(_ configurationData: ConfigurationDataModel)
}

protocol EnvironmentVMOutput {
    func configurationDataIsGet(_ configurationData: ConfigurationDataModel)
    func configurationDataIsSet()
}

class EnvironmentVM {
    // MARK: - VARS
    private var delegate: EnvironmentVMOutput!

    init(delegate: EnvironmentVMOutput) {
        self.delegate = delegate
    }
}

extension EnvironmentVM: EnvironmentVMInput {
    func setConfigurationData(_ configurationData: ConfigurationDataModel) {
        PrefManager.set(configurationData.customerId, forKey: .KEY_CUSTOMER_ID)
        PrefManager.set(configurationData.operationType.rawValue, forKey: .KEY_OPERATION_TYPE)

        PrefManager.set(configurationData.nfc_supportNumber, forKey: .KEY_NFC_SUPPORT_NUMBER)
        PrefManager.set(configurationData.nfc_birthDate, forKey: .KEY_NFC_BIRTH_DATE)
        PrefManager.set(configurationData.nfc_expirationDate, forKey: .KEY_NFC_EXPIRATION_DATE)
        PrefManager.set(configurationData.nfc_issuer, forKey: .KEY_NFC_ISSUER)
        PrefManager.set(configurationData.nfc_documentType.rawValue, forKey: .KEY_NFC_DOCUMENT_TYPE)

        delegate.configurationDataIsSet()
    }

    func getConfigurationData() {
        delegate.configurationDataIsGet(ConfigurationDataModel())
    }
}

struct ConfigurationDataModel {
    let version: String

    let customerId: String
    let operationType: OperationType
    let nfc_supportNumber: String
    let nfc_birthDate: String
    let nfc_expirationDate: String
    let nfc_issuer: String
    let nfc_documentType: NfcDocumentType

    init(customerId: String,
         operationType: OperationType,
         nfc_supportNumber: String,
         nfc_birthDate: String,
         nfc_expirationDate: String,
         nfc_issuer: String,
         nfc_documentType: NfcDocumentType)
    {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""

        self.version = "General - Versión: \(version) (\(build))"
        self.customerId = customerId
        self.operationType = operationType
        self.nfc_supportNumber = nfc_supportNumber
        self.nfc_birthDate = nfc_birthDate
        self.nfc_expirationDate = nfc_expirationDate
        self.nfc_issuer = nfc_issuer
        self.nfc_documentType = nfc_documentType
    }

    init() {
        self.init(
            customerId: PrefManager.get(String.self, forKey: .KEY_CUSTOMER_ID) ?? "",
            operationType: PrefManager.get(.ONBOARDING,
                                           forKey: .KEY_OPERATION_TYPE),
            nfc_supportNumber: PrefManager.get(String.self, forKey: .KEY_NFC_SUPPORT_NUMBER) ?? "",
            nfc_birthDate: PrefManager.get(String.self, forKey: .KEY_NFC_BIRTH_DATE) ?? "",
            nfc_expirationDate: PrefManager.get(String.self, forKey: .KEY_NFC_EXPIRATION_DATE) ?? "",
            nfc_issuer: PrefManager.get(String.self, forKey: .KEY_NFC_ISSUER) ?? "",
            nfc_documentType: PrefManager.get(.ID_CARD,
                                              forKey: .KEY_NFC_DOCUMENT_TYPE)
        )
    }
}

enum NfcDocumentType: String, CaseIterable {
    case ID_CARD
    case PASSPORT
}
