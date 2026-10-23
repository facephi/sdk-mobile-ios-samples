//
//  SelphIDConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphidClassicComponent

extension SdkConfigurationManager {
    /// Same as Android SdkData.SELPHID_RESOURCES: widget resources zip bundled with the app.
    static let SELPHID_RESOURCES: String = Bundle.main.path(
        forResource: "fphi-selphid-widget-resources-sdk",
        ofType: "zip"
    ) ?? ""

    /// Equivalent of Android DemoSelphIDClassic SdkData.getSelphIDConfiguration.
    /// Note: the iOS classic SelphIDConfigurationData has no `fullscreen` field, so that option is not applied.
    static func selphIDConfiguration(
        showTutorial: Bool,
        showPreviousTip: Bool,
        showDiagnostic: Bool,
        wizardMode: Bool,
        showResultAfterCapture: Bool,
        scanMode: SelphIDScanMode,
        specificData: String,
        fullscreen: Bool,
        documentType: SelphIDDocumentType,
        documentSide: SelphIDDocumentSide,
        generateRawImages: Bool
    ) -> SelphIDConfigurationData {
        var configSelphID = SelphIDConfigurationData()

        configSelphID.showTutorial = showTutorial
        configSelphID.showPreviousTip = showPreviousTip
        configSelphID.showDiagnostic = showDiagnostic
        configSelphID.wizardMode = wizardMode
        configSelphID.showResultAfterCapture = showResultAfterCapture
        configSelphID.scanMode = scanMode
        configSelphID.specificData = specificData
        configSelphID.documentType = documentType
        configSelphID.documentSide = documentSide
        configSelphID.timeout = .LONG
        configSelphID.generateRawImages = generateRawImages
        configSelphID.resourcesPath = SELPHID_RESOURCES

        return configSelphID
    }
}
