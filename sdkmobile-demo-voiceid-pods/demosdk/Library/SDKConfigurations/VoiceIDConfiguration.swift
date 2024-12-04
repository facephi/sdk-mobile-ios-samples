//
//  VoiceIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import voiceIDComponent

extension SdkConfigurationManager {
    static var voiceIDConfiguration: EnvironmentAudioRecordingData {
        var configVoiceID = EnvironmentAudioRecordingData(
            phrases: ["Facephi Biometría"],
            showTutorial: true)
        
        return configVoiceID
    }
}
