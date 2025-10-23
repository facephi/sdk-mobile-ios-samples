//
//  SelphiConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphiComponent

extension SdkConfigurationManager {
    static var selphiConfiguration: SelphiConfigurationData {
        var configSelphi = SelphiConfigurationData()
        
        let resourcesSelphi: String = {
            let selphiZipName = "fphi-selphi-widget-resources-sdk"
            return Bundle.main.path(
                forResource: selphiZipName,
                ofType: "zip") ?? ""
        }()
        
        configSelphi.debug = false
        configSelphi.livenessMode = SelphiFaceLivenessMode.PASSIVE
        configSelphi.stabilizationMode = false
        configSelphi.templateRawOptimized = true
        configSelphi.qrMode = false
        configSelphi.resourcesPath = resourcesSelphi
        configSelphi.showDiagnostic = true
        
        return configSelphi
    }
}
