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

        configSelphi.livenessMode = .LIVENESS_PASSIVE
        configSelphi.qrConfiguration.enableQrReader = false
        configSelphi.facialConfiguration.selphiCameraConfiguration.showTutorial = true
        configSelphi.facialConfiguration.selphiCameraConfiguration.showPreviousTip = true
        configSelphi.facialConfiguration.selphiCameraConfiguration.showDiagnostic = true
        configSelphi.facialConfiguration.showAfterCapture = true
        configSelphi.facialConfiguration.selphiCameraConfiguration.cameraPreferred = .FRONT
        configSelphi.maxAttempts = 3
        configSelphi.vibrationEnabled = true

        return configSelphi
    }
}
