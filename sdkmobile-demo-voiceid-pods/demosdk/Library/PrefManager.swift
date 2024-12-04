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
    case KEY_OPERATION_TYPE
    case KEY_NFC_SUPPORT_NUMBER
    case KEY_NFC_BIRTH_DATE
    case KEY_NFC_EXPIRATION_DATE
    case KEY_NFC_ISSUER
    case KEY_NFC_DOCUMENT_TYPE
}

class PrefManager: PreferencesProtocol {
    typealias Enumeration = EnvironmentPreferences

    static func get<T>(_ defaultValue: T, forKey: EnvironmentPreferences) -> T where T: RawRepresentable {
        var defaultDocumentType = defaultValue

        if let rawValue = PrefManager.get(T.RawValue.self, forKey: forKey) {
            defaultDocumentType = T(rawValue: rawValue) ?? defaultValue
        }

        return defaultDocumentType
    }
}

