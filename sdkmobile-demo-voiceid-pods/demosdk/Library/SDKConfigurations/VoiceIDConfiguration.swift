//
//  VoiceIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import voiceIDComponent

extension SdkConfigurationManager {
    static var voiceIDConfiguration: VoiceConfigurationData {
        var configVoiceID = VoiceConfigurationData(phrases: ["Facephi Biometría"],
                                                   showTutorial: true,
                                                   extractionTimeout: 50000,
                                                   showDiagnostic: true, 
                                                   vibrationEnabled: false,
                                                   enableQualityCheck: false)
        
        return configVoiceID
    }
}
