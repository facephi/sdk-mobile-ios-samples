//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation

struct SdkConfigurationManager {
    static let APIKEY_LICENSING = "licensingApiKey"
    static let LICENSING_URL = URL(string: "licensingUrl")!
    static let FLOW_ID = "flowId"
    
    static let VALIDATIONS_APIKEY_DEV = "devApiKey"
    static let VALIDATIONS_BASE_URL_DEV = "devUrl"
    
    static let VALIDATIONS_APIKEY_STG = "stgApiKey"
    static let VALIDATIONS_BASE_URL_STG = "stgUrl"
    
    static let customerId = "onboarding-fileuploader-clienters-ios"
    static let email = "onboarding-fileuploader@clienters-ios"
    
    static var validationsUrl: String = ""
    static var validationsApiKey: String = ""
    static var flowId: String = ""
    static var trackingVersionTag: String = ""

    static func setTrackingVersion(trackingVersion: TrackingVersion?) {
        switch trackingVersion {
        case .v2_DEV:
            trackingVersionTag = "V2_DEV"
            validationsApiKey = SdkConfigurationManager.VALIDATIONS_APIKEY_DEV
            validationsUrl = SdkConfigurationManager.VALIDATIONS_BASE_URL_DEV
            flowId = SdkConfigurationManager.FLOW_ID
        case .v2_STG, nil:
            trackingVersionTag = "V2_STG"
            validationsApiKey = SdkConfigurationManager.VALIDATIONS_APIKEY_STG
            validationsUrl = SdkConfigurationManager.VALIDATIONS_BASE_URL_STG
            flowId = SdkConfigurationManager.FLOW_ID
        }
    }
}
