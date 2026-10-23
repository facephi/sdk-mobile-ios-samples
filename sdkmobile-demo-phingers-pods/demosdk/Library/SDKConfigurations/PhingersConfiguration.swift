//
//  PhingersConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import phingersTFComponent

extension SdkConfigurationManager {
    /// Same parameters as Android DemoPhingers SdkData.getConfiguration.
    static func phingersConfiguration(
        showPreviousTip: Bool,
        showDiagnostic: Bool,
        liveness: Bool,
        captureOrientation: ReticleOrientation,
        fingerFilter: FingerFilter,
        showPreviousFingerSelector: Bool
    ) -> PhingersConfigurationData {
        var configPhingers = PhingersConfigurationData()

        configPhingers.showPreviousTip = showPreviousTip
        configPhingers.showPreviousFingerSelector = showPreviousFingerSelector
        configPhingers.useLiveness = liveness
        configPhingers.showDiagnostic = showDiagnostic
        configPhingers.reticleOrientation = captureOrientation
        configPhingers.fingerFilter = fingerFilter

        return configPhingers
    }
}
