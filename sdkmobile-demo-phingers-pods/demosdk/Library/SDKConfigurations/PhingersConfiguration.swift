//
//  PhingersConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import phingersComponent

extension SdkConfigurationManager {
    static var phingersConfiguration: PhingersConfigurationData{
        var configPhingers = PhingersConfigurationData()
        
        configPhingers.useFlash = true
        configPhingers.returnProcessedImage = true
        configPhingers.returnFingerprintTemplate = .NONE
        configPhingers.showTutorial = true
        configPhingers.reticleOrientation = .LEFT
        configPhingers.extractionTimeout = 60000
        
        return configPhingers
    }
}
