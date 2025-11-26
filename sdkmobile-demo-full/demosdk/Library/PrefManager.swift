//
//  PrefManager.swift
//  demosdk
//
//  Created by Carlos Cantos on 5/9/23.
//

import Foundation

enum EnvironmentPreferences: String, Preference {
    case KEY_ENVIRONMENT
    case KEY_CUSTOMER_ID
    case KEY_FLOW_ID
    case KEY_OPERATION_TYPE
    case KEY_LOCALE
    case KEY_NFC_SUPPORT_NUMBER
    case KEY_NFC_BIRTH_DATE
    case KEY_NFC_EXPIRATION_DATE
    case KEY_NFC_ISSUER
    case KEY_NFC_DOCUMENT_TYPE
    
    case KEY_VOICE_ID_PHRASES
    case KEY_VOICE_ID_MIN_AUDIO_LENGTH
    case KEY_VOICE_ID_MIN_SPEECH_LENGTH
    case KEY_VOICE_ID_MAX_SILENCE_LENGTH
    case KEY_VOICE_ID_MIN_SNR
    case KEY_VOICE_ID_MIN_AUDIO_FOR_ANALYSIS
    case KEY_VOICE_ID_MIN_FEEDBACK_TIME
    case KEY_VOICE_ID_SHOW_TUTORIAL
    
    case KEY_LAUNCH_MAIN_BACKGROUND

}

class PrefManager: PreferencesProtocol {
    typealias Enumeration = EnvironmentPreferences

    static func get<T>(_ defaultValue: T, forKey: EnvironmentPreferences) -> T where T: RawRepresentable {
        var newValue = defaultValue

        if let rawValue = PrefManager.get(T.RawValue.self, forKey: forKey) {
            newValue = T(rawValue: rawValue) ?? defaultValue
        }

        return newValue
    }
}

