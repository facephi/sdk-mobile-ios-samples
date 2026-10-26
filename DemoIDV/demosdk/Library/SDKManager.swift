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
import trackingComponent
import UIKit
import videoRecordingComponent

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    private let TAG = "APP_MANAGER"
    private var flowController: FlowController?

    // MARK: - INIT SDK
    /// Same as Android SdkData.getInitConfiguration (trackingController = TrackingController()).
    /// `trackingError` replaces Android's TrackingErrorController (iOS reports tracking errors through TrackingController).
    func initSdk(trackingError: @escaping (String) -> Void, output: @escaping (SdkResult<String>) -> Void) {
        let trackingController = TrackingController(trackingError: trackingError)

        let analyticsOutput: AnalyticsOutput = { time, componentName, eventType, info in
            print("APP - *** \(Date(timeIntervalSince1970: time / 1000)) - \(componentName) - \(eventType) - \(info)")
        }

        SDKController.shared.initSdk(
            licensingUrl: SdkConfigurationManager.LICENSING_URL,
            apiKey: SdkConfigurationManager.APIKEY_LICENSING,
            output: output,
            trackingController: trackingController,
            analyticsOutput: analyticsOutput
        )
    }

    // MARK: - FLOWS
    func getFlowIntegrationData() -> [IntegrationFlowData] {
        FlowController.getFlowIntegrationData()
    }

    /// Same as Android SdkData.getIDVFlowConfigurationData:
    /// FSelphiController, FSelphIDController(extractors), FStopVideoRecordingController, FVideoRecordingController.
    func launchFlow(flowId: String, viewController: UIViewController, output: @escaping (SdkFlowResult) -> Void) {
        log("LAUNCH FLOW \(flowId)")

        let selphiController = SelphiController(data: nil, output: { _ in }, viewController: viewController)
        let selphIdController = SelphIDController(
            data: nil,
            extractors: SelphIDExtractorProvider.makeAllExtractors(),
            output: { _ in },
            viewController: viewController
        )
        let videoRecordingController = VideoRecordingController(viewController: viewController, output: { _ in })
        let stopVideoRecordingController = StopVideoRecordingController(
            videoRecordingController: videoRecordingController,
            output: { _ in }
        )

        let controllers: [IFlowableController] = [
            selphiController,
            selphIdController,
            stopVideoRecordingController,
            videoRecordingController,
        ]

        let flowConfigurationData = FlowConfigurationData(
            id: flowId,
            controllers: controllers,
            customerId: SdkConfigurationManager.CUSTOMER_ID
        )

        let flowController = FlowController(flowConfigurationData: flowConfigurationData, output: output)
        self.flowController = flowController
        SDKController.shared.launch(controller: flowController)
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
