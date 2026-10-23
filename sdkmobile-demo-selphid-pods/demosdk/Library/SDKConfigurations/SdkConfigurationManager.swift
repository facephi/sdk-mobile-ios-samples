//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//
//  Equivalent of Android SdkData.kt (DemoSelphID).
//

import Foundation
import sdk

struct SdkConfigurationManager {
    // ************** LICENSE **************
    static let onlineLicensing = true
    static let APIKEY_LICENSING = "licensingApiKey"
    static let LICENSING_URL = URL(string: "licensingUrl")!

    // swiftlint:disable all
    static let license = ""

    // ************** DATA **************
    static let CUSTOMER_ID = "demo_onboarding@email.com"
    static let OPERATION_TYPE: OperationType = .ONBOARDING
}
