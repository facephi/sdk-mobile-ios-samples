//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation

struct SdkConfigurationManager {
    static let base64 = " "
    static let CUSTOMER_ID = "sdk-voice-ios@ejemplo"
    static let APIKEY_LICENSING = ""
    static let LICENSING_URL = URL(string: "LicensingURL")!
    static let CUSTOM_TENANT_ID = ""
    static let audiosDirectory = getDocumentsDirectory().appendingPathComponent("audios")
    static let onlineLicensing = true
    
    // swiftlint:disable all
    static let license = ""
}


