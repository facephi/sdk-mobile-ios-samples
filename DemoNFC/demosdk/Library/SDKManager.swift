//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import nfcComponent
import sdk
import selphidComponent
import statusComponent
import termsConditionsComponent
import tokenizeComponent
import trackingComponent
import UIKit

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    private let TAG = "APP_MANAGER"
    private var nfcStateObserver: NfcStateObserver?

    // MARK: - INIT SDK
    func initSdk(output: @escaping (SdkResult<String>) -> Void) {
        let trackingController = TrackingController(trackingError: { [weak self] trackingError in
            self?.log("Tracking Error: \(trackingError)")
        })
        let tokenizeController = TokenizeController()
        let statusController = StatusController()

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
    public func newOperation(output: @escaping (SdkResult<String>) -> Void) {
        log("newOperation - customerId - \(SdkConfigurationManager.CUSTOMER_ID)")
        SDKController.shared.newOperation(
            operationType: SdkConfigurationManager.OPERATION_TYPE,
            customerId: SdkConfigurationManager.CUSTOMER_ID,
            output: output
        )
    }

    // MARK: - COMPONENTS
    public func launchTermsConditions(
        viewController: UIViewController,
        text: String,
        output: @escaping (SdkResult<TermsConditionsResult>) -> Void
    ) {
        log("LAUNCH TERMS CONDITIONS")
        let controller = TermsConditionsController(
            data: TermsConditionsConfigurationData(termsConditions: text),
            output: output,
            viewController: viewController
        )
        SDKController.shared.launch(controller: controller)
    }

    public func launchSelphId(
        viewController: UIViewController,
        selphIDConfigurationData: SelphIDConfigurationData,
        output: @escaping (SdkResult<SelphIDResult>) -> Void
    ) {
        log("LAUNCH SELPHID")
        let controller = SelphIDController(
            data: selphIDConfigurationData,
            extractors: SelphIDExtractorProvider.makeAllExtractors(),
            output: output,
            viewController: viewController
        )
        SDKController.shared.launch(controller: controller)
    }

    /// Android NfcController exposes `debugLogs` and `state` callbacks; on iOS the widget
    /// events are received through `stateDelegate` (NfcWidgetDelegateProtocol).
    public func launchNfc(
        viewController: UIViewController,
        nfcConfigurationData: NfcConfigurationData,
        state: @escaping (String) -> Void,
        output: @escaping (SdkResult<NfcResult>) -> Void
    ) {
        log("LAUNCH NFC")
        let observer = NfcStateObserver(state: state)
        nfcStateObserver = observer
        let controller = NfcController(
            data: nfcConfigurationData,
            viewController: viewController,
            output: output,
            stateDelegate: observer
        )
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

private final class NfcStateObserver: NfcWidgetDelegateProtocol {
    private let state: (String) -> Void

    init(state: @escaping (String) -> Void) {
        self.state = state
    }

    func captureFinished() { state("CAPTURE_FINISHED") }
    func captureCancelled() { state("CAPTURE_CANCELLED") }
    func captureTimeout() { state("CAPTURE_TIMEOUT") }
    func captureFailed(_ error: (any Error)!) { state("CAPTURE_FAILED \(error.map { "\($0)" } ?? "")") }
    func onEvent(_ time: Date!, type: String!, info: String!) { state("\(type ?? "") \(info ?? "")") }
}
