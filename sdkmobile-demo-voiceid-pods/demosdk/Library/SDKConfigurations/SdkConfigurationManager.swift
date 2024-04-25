//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation

struct SdkConfigurationManager {
    static let base64 = " "
    static let CUSTOMER_ID = "sdk-voiceid-ios@ejemplo"
    static let APIKEY_LICENSING = ""
    static let LICENSING_URL = URL(string: "https://license.identity-platform.dev")!
    static let CUSTOM_TENANT_ID = ""
    static let audiosDirectory = getDocumentsDirectory().appendingPathComponent("audios")

    // swiftlint:disable all
    static let license = ""
}


