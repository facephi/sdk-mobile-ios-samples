//
//  VoiceIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import voiceIDComponent

extension SdkConfigurationManager {
    static var voiceIDConfiguration: VoiceConfigurationData {
        var configVoiceID = VoiceConfigurationData(
            phrases: ["Facephi Biometria"],
            showTutorial: true)
        configVoiceID.showDiagnostic = true
        configVoiceID.vibrationEnabled = true
        configVoiceID.enableQualityCheck = true
        configVoiceID.showPreviousTip = true
        configVoiceID.extractionTimeout = 5000
        
        return configVoiceID
    }
}
