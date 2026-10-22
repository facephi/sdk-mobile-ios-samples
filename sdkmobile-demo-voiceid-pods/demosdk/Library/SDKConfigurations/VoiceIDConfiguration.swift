//
//  VoiceIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import voiceIDComponent

extension SdkConfigurationManager {
    static var voiceIDConfiguration: VoiceConfigurationData {
        VoiceConfigurationData(
            phrases: ["Facephi Biometria"],
            showTutorial: true,
            extractionTimeout: 5000,
            showDiagnostic: true,
            vibrationEnabled: true,
            enableQualityCheck: true,
            showPreviousTip: true
        )
    }
}
