//
//  SdkConfigurationManager.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import core
import Foundation

struct SdkConfigurationManager {
    /// Defaults for session visual options when not set in Environment configuration.
    static let defaultSessionVisualDebugMode = true
    static let defaultSessionRoundedCornerShape = 15
    static let defaultSessionOverlayOpacityPercent = 55

    /// KMP widgets (Selphi / SelphID / Phingers). Applied via `SDKController.initSdk(sessionVisualOptions:)`.
    static var demoSessionVisualOptions: SdkVisualSessionOptions {
        SdkVisualSessionOptions(
            debugMode: PrefManager.get(Bool.self, forKey: .KEY_SESSION_VISUAL_DEBUG) ?? defaultSessionVisualDebugMode,
            roundedCornerShape: PrefManager.get(Int.self, forKey: .KEY_SESSION_VISUAL_ROUNDED_CORNER)
                ?? defaultSessionRoundedCornerShape,
            overlayOpacityPercent: PrefManager.get(Int.self, forKey: .KEY_SESSION_VISUAL_OPACITY_PERCENT)
                ?? defaultSessionOverlayOpacityPercent
        )
    }

    static let base64 = " "
    static let email = "sdk-full-clienters-ios@ejemplo"

    static let APIKEY_LICENSING_V2_MIDAPI = ""
    static let APIKEY_LICENSING = ""
    static let LICENSING_URL = URL(string: "LICENSING_URL")!
    static let FLOW_ID = ""

    static let APIKEY_LICENSING_V2_STG = ""
    static let APIKEY_LICENSING_V2_LIVEKIT = ""
    static let APIKEY_LICENSING_IDV_STG = ""

    static let LICENSING_URL_STG = URL(string: "LICENSING_URL_STG")!
    static let LICENSING_URL_IDV_DEV = URL(string: "LICENSING_URL_IDV_DEV")!
    static let LICENSING_URL_IDV_STG = URL(string: "LICENSING_URL_IDV_STG")!

    static let FLOW_ID_V2_STG = ""
    static let FLOW_ID_IDV = ""

    static let customerId = "sdk-full-clienters-ios"
    static let CUSTOM_TENANT_ID = ""
    static let audiosDirectory = getDocumentsDirectory().appendingPathComponent("audios")
    static let onlineLicensing = true

    /// Offline license JSON for local init (fill locally; do not commit real envelopes to the public repo).
    static let license_MIDAPI = ""
    static let licenseSTG = ""
    static let license_DEV_trackingV3_videoidV3_videorecV3_aiocrV2_videocallV2 = ""
    static let brokenLicenseSTGForSelphIDCrash = ""
    static let licenseDevWithRGL = ""
    static let licenseDevWithApiAuth = ""
    static let license_IDV = ""
    static let license_Proxy = ""

    /// When true, `SDKManager.launchSelphi` / `launchPhingers` pass the demo KMP custom camera overlay via each SDK component.
    static var useDemoKmpCustomCameraOverlay: Bool {
        get { PrefManager.get(Bool.self, forKey: .KEY_DEMO_KMP_CUSTOM_CAMERA_OVERLAY) ?? false }
        set { PrefManager.set(newValue, forKey: .KEY_DEMO_KMP_CUSTOM_CAMERA_OVERLAY) }
    }

    static var validationsUrl: String = ""
    static var validationsApiKey: String = ""
}
