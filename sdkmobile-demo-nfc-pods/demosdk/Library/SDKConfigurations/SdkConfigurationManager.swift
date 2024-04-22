//
//  SDKConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation

struct SdkConfigurationManager {
    static let base64 = " "
    static let CUSTOMER_ID = "sdk-classic-ios@ejemplo"
    static let APIKEY_LICENSING: String = "9HdltkmH3MmKA7TgxLmWrlG8veBLnw0qLLB9F9OL"
    static let LICENSING_URL = URL(string: "https://license.identity-platform.dev")!
    static let LICENSE = ""
    static let BASE_URL = "https://external-selphid-sdk.facephi.dev/"
    static let METHOD_PASSIVE_LIVENES = "api/v1/selphid/passive-liveness/evaluate"
    static let METHOD_AUTH_FACIAL = "api/v1/selphid/authenticate-facial/document/face-image"
    static let CUSTOM_TENANT_ID = "e9b039fa-0a2f-4149-9acc-a7e20a46464e"
    
    static let SELPHI_RESOURCES = "fphi-selphi-widget-resources-sdk"
    static let SELPHID_RESOURCES = "fphi-selphid-widget-resources-sdk"
}
