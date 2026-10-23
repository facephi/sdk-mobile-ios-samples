//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt + ui/MainState.kt (DemoIDV).
//

import CoreLocation
import sdk
import SwiftUI

final class MainViewModel: ObservableObject {
    // MainState
    @Published private(set) var flowList: [IntegrationFlowData] = []
    @Published private(set) var sdkReady = false
    @Published private(set) var flowActive = false
    @Published private(set) var logs = ""

    let version = sdk.Constants.libraryPackageVersion

    private let locationManager = CLLocationManager()
    private var initialized = false
    private var lastOperationId: String?

    func initSdk() {
        guard !initialized else { return }
        initialized = true

        // Same as Android MainActivity (location permission request)
        locationManager.requestWhenInUseAuthorization()

        SDKManager.shared.initSdk(
            trackingError: { [weak self] error in
                self?.log("Tracking Error: \(error)")
            },
            output: { [weak self] result in
                guard let self else { return }
                if result.finishStatus == .STATUS_OK {
                    self.loadFlows(retry: true)
                    self.log("INIT SDK OK")
                } else {
                    self.log("INIT SDK ERROR: \(result.errorType)")
                }
            }
        )
    }

    func start(flowId: String?) {
        guard let flowId else {
            log("No flow selected")
            return
        }
        guard let viewController = UIApplication.topViewController else { return }

        flowActive = true
        lastOperationId = nil
        log("Launch flow \(flowId)")

        SDKManager.shared.launchFlow(flowId: flowId, viewController: viewController) { [weak self] flowResult in
            guard let self else { return }
            // Flow info
            if let key = flowResult.step.flatMap(Self.stepKey) {
                self.log("New Step: \(key)")
            }

            // Operation ID
            if let operationId = flowResult.operationId, !operationId.isEmpty, operationId != self.lastOperationId {
                self.lastOperationId = operationId
                self.log("New Operation: \(operationId)")
            }

            // Flow finished flag
            if flowResult.flowFinish {
                self.onMain { self.flowActive = false }
                self.log("Flow Finish")
            }
        }
    }

    func clearLogs() {
        logs = ""
    }

    /// iOS FlowStep does not expose `key` publicly (Android: flowResult.step?.key), so it is read by reflection.
    private static func stepKey(_ step: FlowStep) -> String? {
        Mirror(reflecting: step).children.first { $0.label == "key" }?.value as? String
    }

    /// Android reads SDKController.getFlowIntegrationData() right after INIT SDK OK.
    /// On iOS the flow list may arrive slightly later, so it is read again once if empty.
    private func loadFlows(retry: Bool) {
        onMain {
            let flows = SDKManager.shared.getFlowIntegrationData()
            if flows.isEmpty && retry {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.loadFlows(retry: false) }
                return
            }
            self.flowList = flows
            self.sdkReady = true
        }
    }

    private func log(_ message: String) {
        print("APP - \(message)")
        onMain { self.logs += "\n" + message }
    }

    private func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }
}

extension UIApplication {
    /// Top-most presented view controller, used to present the SDK components.
    static var topViewController: UIViewController? {
        let window = shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
