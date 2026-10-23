//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Equivalent of Android SdkData.kt (DemoRecordingOnboarding).
//

import Foundation
import sdk
import videoRecordingComponent

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

    // VideoRecording DATA
    static var videoRecordingConfiguration: VideoRecordingConfigurationData {
        VideoRecordingConfigurationData()
    }
}
