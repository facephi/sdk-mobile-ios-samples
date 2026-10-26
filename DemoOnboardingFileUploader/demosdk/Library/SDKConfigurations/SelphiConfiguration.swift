//
//  SelphiConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphiComponent

extension SdkConfigurationManager {
    /// Defaults aligned with Android DemoOnboarding (SdkData.getSelphiConfiguration / SelphiComponentCard).
    static var selphiConfiguration: SelphiConfigurationData {
        selphiConfiguration()
    }

    static func selphiConfiguration(
        showTutorial: Bool = true,
        showPreviousTip: Bool = true,
        showDiagnostic: Bool = true,
        cameraPreferred: SelphiCamera = .FRONT,
        livenessMode: SelphiFaceLivenessMode = .LIVENESS_PASSIVE,
        maxAttempts: Int = 3,
        iadEnabled: Bool = false
    ) -> SelphiConfigurationData {
        var configSelphi = SelphiConfigurationData()

        configSelphi.livenessMode = livenessMode
        configSelphi.maxAttempts = maxAttempts
        configSelphi.facialConfiguration.selphiCameraConfiguration.cameraPreferred = cameraPreferred
        configSelphi.facialConfiguration.selphiCameraConfiguration.showTutorial = showTutorial
        configSelphi.facialConfiguration.selphiCameraConfiguration.showPreviousTip = showPreviousTip
        configSelphi.facialConfiguration.selphiCameraConfiguration.showDiagnostic = showDiagnostic
        configSelphi.iadConfiguration.enabled = iadEnabled

        return configSelphi
    }
}
