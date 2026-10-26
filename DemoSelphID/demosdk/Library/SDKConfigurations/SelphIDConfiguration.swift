//
//  SelphIDConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphidComponent

extension SdkConfigurationManager {
    /// Defaults aligned with Android DemoSelphID (SdkData.getSelphIDConfiguration / SelphIDComponentCard).
    static var selphIDConfiguration: SelphIDConfigurationData {
        selphIDConfiguration()
    }

    static func selphIDConfiguration(
        showTutorial: Bool = true,
        showPreviousTip: Bool = true,
        showDiagnostic: Bool = true,
        showDocumentSelector: Bool = true,
        showResultAfterCapture: Bool = true,
        documentType: SelphIDDocumentType = .ALL,
        captureMode: SelphIDCaptureMode = .STANDARD,
        generateRawImages: Bool = false,
        maxAttempts: Int = 3
    ) -> SelphIDConfigurationData {
        var configSelphID = SelphIDConfigurationData()

        configSelphID.timeout = SelphIDTimeout.LONG.milliseconds
        configSelphID.maxAttempts = maxAttempts

        configSelphID.uiConfiguration.showTutorial = showTutorial
        configSelphID.uiConfiguration.showPreviousTip = showPreviousTip
        configSelphID.uiConfiguration.showDiagnostic = showDiagnostic
        configSelphID.uiConfiguration.showAfterCapture = showResultAfterCapture
        configSelphID.uiConfiguration.showDocumentSelector = showDocumentSelector
        // Required so the selector's continue button isn't stuck disabled (same as Android).
        configSelphID.uiConfiguration.defaultCountry = "ES"
        configSelphID.uiConfiguration.defaultDocumentType = documentType

        configSelphID.extractionConfiguration.captureMode = captureMode
        configSelphID.extractionConfiguration.documentTypes = [documentType]
        configSelphID.extractionConfiguration.generateRawImages = generateRawImages

        return configSelphID
    }
}
