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
import statusComponent
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

        let statusController = StatusController()
        ThemeStatusManager.setup(theme: CustomThemeStatus())

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
                statusController: statusController,
                analyticsOutput: analyticsOutput
            )
        } else {
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                output: output,
                trackingController: trackingController,
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
    public func launchSelphi(setTracking: Bool, viewController: UIViewController, selphiConfigurationData: SelphiConfigurationData, output: @escaping (SdkResult<SelphiResult>) -> Void) {
        log("LAUNCH SELPHI")

        let controller = SelphiController(data: selphiConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }

    public func launchSelphId(setTracking: Bool, viewController: UIViewController, selphIDConfigurationData: SelphIDConfigurationData, output: @escaping (SdkResult<SelphIDResult>) -> Void) {
        log("LAUNCH SELPHID")

        let controller = SelphIDController(
            data: selphIDConfigurationData,
            extractors: SelphIDExtractorProvider.makeAllExtractors(),
            output: output,
            viewController: viewController
        )
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
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
