//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//
//  Equivalent of Android SdkData.kt (DemoIDV).
//

import Foundation

struct SdkConfigurationManager {
    // ************** LICENSE **************
    static let APIKEY_LICENSING = "licensingApiKey"
    static let LICENSING_URL = URL(string: "licensingUrl")!

    // ************** DATA **************
    static let CUSTOMER_ID = "demo_onboarding_idv@email.com"
}
