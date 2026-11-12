//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import sdk
import selphidClassicComponent
import statusComponent
import tokenizeComponent
import trackingComponent
import UIKit

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    private let TAG = "APP_MANAGER"

    // MARK: - INIT SDK
    func initSdk(log: @escaping (String) -> Void) {
        let trackingController = TrackingController(trackingError: { trackingError in
            log("Tracking Error: \(trackingError)")
        })
        let tokenizeController = TokenizeController()
        let statusController = StatusController()

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

        if SdkConfigurationManager.onlineLicensing {
            SDKController.shared.initSdk(
                licensingUrl: SdkConfigurationManager.LICENSING_URL,
                apiKey: SdkConfigurationManager.APIKEY_LICENSING,
                output: output,
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                statusController: statusController,
                analyticsOutput: analyticsOutput
            )
        } else {
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                output: output,
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                statusController: statusController,
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
    public func launchSelphId(viewController: UIViewController, selphIDConfigurationData: SelphIDConfigurationData, output: @escaping (SdkResult<SelphIDResult>) -> Void) {
        log("LAUNCH SELPHID")

        let controller = SelphIDController(data: selphIDConfigurationData, output: output, viewController: viewController)
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
