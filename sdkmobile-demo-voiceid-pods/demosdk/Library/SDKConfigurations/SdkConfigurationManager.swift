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
    static let LICENSING_URL = URL(string: "https://license.identity-platform.dev")!
    static let CUSTOM_TENANT_ID = ""
    static let audiosDirectory = getDocumentsDirectory().appendingPathComponent("audios")

    // swiftlint:disable all
    
    //LICENSING: Set true if you want to use online licensing, set false otherwise
    static let onlineLicensing = true
    
    //AUTO LICENSING: Paste your API Key here to use online licensing
    static let APIKEY_LICENSING = ""
    
    //MANUAL LICENSE: Paste your license here to use manual licensing
    static let license = """
"""
}


