//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//
//  Equivalent of Android SdkData.kt (DemoNFC).
//

import Foundation
import nfcComponent
import sdk
import selphidComponent

enum DocumentType: String, CaseIterable {
    case ID_CARD, PASSPORT, FOREIGN_CARD
}

struct SdkConfigurationManager {
    // ************** LICENSE **************
    static let onlineLicensing = true
    static let APIKEY_LICENSING = "licensingApiKey"
    static let LICENSING_URL = URL(string: "licensingUrl")!

    // swiftlint:disable all
    static let license = ""

    // ************** DATA **************
    static let CUSTOMER_ID = "nfc-demo@email.com"
    static let OPERATION_TYPE: OperationType = .ONBOARDING

    static func getSelphIdConfig(_ docType: DocumentType) -> SelphIDConfigurationData {
        switch docType {
        case .ID_CARD: return idCardConfig
        case .PASSPORT: return passportConfig
        case .FOREIGN_CARD: return foreignCardConfig
        }
    }

    static func getNfcDocType(_ docType: DocumentType) -> NfcDocumentType {
        switch docType {
        case .ID_CARD: return .ID_CARD
        case .PASSPORT: return .PASSPORT
        case .FOREIGN_CARD: return .FOREIGN_CARD
        }
    }

    // documentSide=BACK (reads the MRZ) maps to captureMode=MRZ; FRONT maps to captureMode=FRONT
    private static var idCardConfig: SelphIDConfigurationData {
        var config = SelphIDConfigurationData()
        config.extractionConfiguration.captureMode = .STANDARD
        config.extractionConfiguration.documentTypes = [.ID_CARD]
        config.extractionConfiguration.documentCountries = ["ES"]
        config.extractionConfiguration.generateRawImages = true
        return config
    }

    private static var passportConfig: SelphIDConfigurationData {
        var config = SelphIDConfigurationData()
        config.extractionConfiguration.captureMode = .FRONT
        config.extractionConfiguration.documentTypes = [.PASSPORT]
        config.extractionConfiguration.generateRawImages = true
        return config
    }

    private static var foreignCardConfig: SelphIDConfigurationData {
        var config = SelphIDConfigurationData()
        config.extractionConfiguration.captureMode = .MRZ
        config.extractionConfiguration.documentTypes = [.FOREIGN_CARD]
        config.extractionConfiguration.documentCountries = ["ES"]
        config.extractionConfiguration.generateRawImages = true
        return config
    }

    /// iOS NfcConfigurationData has no `maxAttempts` (Android does), so it is not forwarded.
    static func getNfcConfig(
        support: String,
        birthDate: String,
        expirationDate: String,
        showPreviousTip: Bool,
        showTutorial: Bool,
        showDiagnostic: Bool,
        skipPACE: Bool,
        extractFace: Bool,
        extractSignature: Bool,
        docType: DocumentType,
        readingProgressStyle: ReadingProgressStyle,
        maxAttempts: Int = 3
    ) -> NfcConfigurationData {
        NfcConfigurationData(
            documentNumber: support, // Num support.
            birthDate: birthDate, // "dd/MM/yyyy"
            expirationDate: expirationDate, // "dd/MM/yyyy"
            documentType: getNfcDocType(docType),
            skipPACE: skipPACE,
            extractFacialImage: extractFace,
            extractSignatureImage: extractSignature,
            showTutorial: showTutorial,
            showDiagnostic: showDiagnostic,
            showPreviousTip: showPreviousTip,
            readingProgressStyle: readingProgressStyle
        )
    }
}
