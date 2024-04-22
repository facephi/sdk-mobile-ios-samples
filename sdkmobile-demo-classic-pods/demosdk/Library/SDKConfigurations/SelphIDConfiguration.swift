//
//  SelphIDConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphidComponent

extension SdkConfigurationManager {
    static var selphIDConfiguration: SelphIDConfigurationData {
        var configSelphID = SelphIDConfigurationData()
        
        let resourcesSelphID: String = {
            let selphiZipName = "fphi-selphid-widget-resources-sdk"
            return Bundle.main.path(
                forResource: selphiZipName,
                ofType: "zip") ?? ""
        }()
        
        configSelphID.debug = true
        configSelphID.wizardMode = true
        configSelphID.showResultAfterCapture = false
        configSelphID.showTutorial = false
        configSelphID.scanMode = SelphIDScanMode.MODE_SEARCH
        configSelphID.specificData = "ES|<ALL>"
        configSelphID.fullscreen = true
        configSelphID.tokenImageQuality = 0.5
        configSelphID.locale = "es"
        configSelphID.documentType = SelphIDDocumentType.ID_CARD
        configSelphID.documentSide = SelphIDDocumentSide.FRONT
        configSelphID.timeout = SelphIDTimeout.LONG
        configSelphID.generateRawImages = true
        configSelphID.translationsContent = ""
        configSelphID.viewsContent = ""
        configSelphID.documentModels = ""
        configSelphID.resourcesPath = resourcesSelphID
        
        return configSelphID
    }
}
