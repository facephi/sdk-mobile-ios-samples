//
//  VoiceIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import voiceIDComponent

extension SdkConfigurationManager {
    /// Same parameters as the VoiceConfigurationData built in Android DemoVoice MainScreen.kt.
    static func voiceIDConfiguration(
        phrases: [String],
        showPreviousTip: Bool,
        showTutorial: Bool,
        showDiagnostic: Bool,
        maxAttempts: Int
    ) -> VoiceConfigurationData {
        VoiceConfigurationData(
            phrases: phrases,
            showTutorial: showTutorial,
            showDiagnostic: showDiagnostic,
            showPreviousTip: showPreviousTip,
            maxAttempts: maxAttempts
        )
    }
}
