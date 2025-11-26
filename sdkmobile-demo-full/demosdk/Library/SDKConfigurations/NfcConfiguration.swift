//
//  NfcConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import nfcComponent

extension SdkConfigurationManager {
    static var nfcConfiguration: NfcConfigurationData {
        // Dates are in dd/MM/yyyy format
        return NfcConfigurationData(documentNumber: PrefManager.get(String.self, forKey: .KEY_NFC_SUPPORT_NUMBER) ?? "",
                                    birthDate: PrefManager.get(String.self, forKey: .KEY_NFC_BIRTH_DATE) ?? "",
                                    expirationDate: PrefManager.get(String.self, forKey: .KEY_NFC_EXPIRATION_DATE) ?? "",
                                    issuer: PrefManager.get(String.self, forKey: .KEY_NFC_ISSUER) ?? "ES",
                                    documentType: PrefManager.get(.ID_CARD, forKey: .KEY_NFC_DOCUMENT_TYPE),
                                    showTutorial: false, showPreviousTip: true)
    }
}



