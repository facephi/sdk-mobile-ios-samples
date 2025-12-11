//
//  PrefManager.swift
//  demosdk
//
//  Created by Carlos Cantos on 5/9/23.
//

import Foundation

enum EnvironmentPreferences: String, Preference {
    case KEY_TRACKING_VERSION
    case KEY_CUSTOMER_ID
    case KEY_FLOW_ID
    case KEY_OPERATION_TYPE
    case KEY_LOCALE
    case KEY_LAUNCH_MAIN_BACKGROUND
    
    //SELPHID
    case KEY_SELPHID_DOCUMENT_TYPE
    case KEY_SELPHID_DOCUMENT_ISSUER
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

