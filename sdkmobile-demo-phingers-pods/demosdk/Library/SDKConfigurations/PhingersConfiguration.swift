//
//  PhingersConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import phingersTFComponent

extension SdkConfigurationManager {
    static var phingersConfiguration: PhingersConfigurationData{
        var configPhingers = PhingersConfigurationData()
        
        configPhingers.showTutorial = true
        configPhingers.showPreviousTip = true
        configPhingers.showDiagnostic = true
        configPhingers.vibrationEnabled = true
        configPhingers.showEllipses = true
        configPhingers.useLiveness = true
        configPhingers.reticleOrientation = .LEFT
        configPhingers.templateType = .NIST_TEMPLATE
        configPhingers.extractionTimeout = 60000
        
        return configPhingers
    }
}
