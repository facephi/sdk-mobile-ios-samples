//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import sdk
import selphiComponent
import selphidComponent
import UIKit
import videoRecordingComponent

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    private let TAG = "APP_MANAGER"
    private var videoRecordingController: VideoRecordingController?

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

        // Same as Android: trackingController = null
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
    public func launchSelphi(viewController: UIViewController, selphiConfigurationData: SelphiConfigurationData, output: @escaping (SdkResult<SelphiResult>) -> Void) {
        log("LAUNCH SELPHI")
        let controller = SelphiController(data: selphiConfigurationData, output: output, viewController: viewController)
        SDKController.shared.launch(controller: controller)
    }

    public func launchSelphId(viewController: UIViewController, selphIDConfigurationData: SelphIDConfigurationData, output: @escaping (SdkResult<SelphIDResult>) -> Void) {
        log("LAUNCH SELPHID")
        let controller = SelphIDController(
            data: selphIDConfigurationData,
            extractors: SelphIDExtractorProvider.makeAllExtractors(),
            output: output,
            viewController: viewController
        )
        SDKController.shared.launch(controller: controller)
    }

    public func launchVideoRecording(viewController: UIViewController, videoRecordingConfigurationData: VideoRecordingConfigurationData, output: @escaping (SdkResult<String>) -> Void) {
        log("LAUNCH VIDEO RECORDING")
        let controller = VideoRecordingController(data: videoRecordingConfigurationData, viewController: viewController, output: output)
        videoRecordingController = controller
        SDKController.shared.launch(controller: controller)
    }

    public func stopVideoRecording(output: @escaping (SdkResult<String>) -> Void) {
        log("STOP VIDEO RECORDING")
        guard let videoRecordingController else {
            output(SdkResult(finishStatus: .STATUS_ERROR, errorType: .OTHER("VideoRecording not started")))
            return
        }
        let controller = StopVideoRecordingController(videoRecordingController: videoRecordingController, output: output)
        SDKController.shared.launch(controller: controller)
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
