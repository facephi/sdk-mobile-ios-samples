//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import sdk
import UIKit
import videocallComponent

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    private let TAG = "APP_MANAGER"
    private var videoCallController: VideoCallController?

    // MARK: - INIT SDK
    func initSdk(log: @escaping (String) -> Void) {
        let output: (SdkResult<String>) -> Void = { sdkResult in
            if sdkResult.finishStatus == .STATUS_OK {
                log("INIT SDK OK")
            } else {
                log("INIT SDK ERROR: \(sdkResult.errorType)")
            }
        }

        let analyticsOutput: AnalyticsOutput = { time, componentName, eventType, info in
            print("APP - *** \(Date(timeIntervalSince1970: time / 1000)) - \(componentName) - \(eventType) - \(info)")
        }

        // Same as Android SdkData: trackingController = null
        if SdkConfigurationManager.onlineLicensing {
            SDKController.shared.initSdk(
                licensingUrl: SdkConfigurationManager.LICENSING_URL,
                apiKey: SdkConfigurationManager.APIKEY_LICENSING,
                output: output,
                analyticsOutput: analyticsOutput
            )
        } else {
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                output: output,
                analyticsOutput: analyticsOutput
            )
        }
    }

    // MARK: - OPERATION
    public func newOperation(operationType: OperationType, customerId: String, output: @escaping (SdkResult<String>) -> Void) {
        log("newOperation - customerId - \(customerId)")
        SDKController.shared.newOperation(operationType: operationType, customerId: customerId, output: output)
    }

    // MARK: - COMPONENTS
    public func launchVideoCall(viewController: UIViewController, videoCallConfigurationData: VideoCallConfigurationData, output: @escaping (SdkResult<VideoCallStatus>) -> Void) {
        log("LAUNCH VIDEO CALL")

        let controller = VideoCallController(data: videoCallConfigurationData, output: output, viewController: viewController)
        videoCallController = controller
        SDKController.shared.launch(controller: controller)
    }

    /// Equivalent of Android StopVideoCallController.
    public func stopVideoCallScreenSharing(output: @escaping (VideoCallScreenSharingState) -> Void) {
        log("VIDEO CALL STOP SCREEN SHARING")
        videoCallController?.stopScreenSharing(output: output)
    }

    // MARK: - SESSION
    public func closeSession() {
        log("closeSession")
        _ = SDKController.shared.closeSession()
    }

    private func log(_ msg: String) {
        print(TAG + " - " + msg)
    }
}
