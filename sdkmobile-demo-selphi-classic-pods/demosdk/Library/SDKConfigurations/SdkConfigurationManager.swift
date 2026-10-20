//
//  SdkConfigurationManager.swift
//  Classic Selphi component sample.
//

import Foundation

struct SdkConfigurationManager {
    static let email = "sdk-selphi-classic-ios@ejemplo"
    static let CUSTOMER_ID = email
    static let APIKEY_LICENSING = ""
    static let LICENSING_URL = URL(string: "LicensingURL")!
    /// Set `false` to test offline envelope in `license` below.
    static let onlineLicensing = true

    /// Offline license JSON (fill locally; do not commit real envelopes to the public repo).
    static let license = ""
}
