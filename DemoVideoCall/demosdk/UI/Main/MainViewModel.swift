//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt (DemoVideoCall).
//

import sdk
import SwiftUI
import videocallComponent

final class MainViewModel: ObservableObject {
    @Published private(set) var logs = ""
    @Published private(set) var newOperationClicked = false
    @Published var videoResult: UIComponentResult = .pending

    let version = sdk.Constants.libraryPackageVersion

    private var initialized = false

    func initSdk() {
        guard !initialized else { return }
        initialized = true

        SDKManager.shared.initSdk { [weak self] message in
            self?.log(message)
        }
    }

    func newOperation() {
        SDKManager.shared.newOperation(
            operationType: SdkConfigurationManager.OPERATION_TYPE,
            customerId: SdkConfigurationManager.CUSTOMER_ID
        ) { [weak self] result in
            if result.errorType == .NO_ERROR {
                self?.log("NEW OPERATION: OK")
                self?.onMain { self?.newOperationClicked = true }
            } else {
                self?.log("NEW OPERATION: Error - \(result.errorType)")
            }
        }
    }

    func launchVideoCall() {
        guard let viewController = UIApplication.topViewController else { return }

        SDKManager.shared.launchVideoCall(
            viewController: viewController,
            videoCallConfigurationData: SdkConfigurationManager.videoCallConfiguration
        ) { [weak self] result in
            guard let self else { return }
            if result.errorType == .NO_ERROR {
                self.log("Video Call: OK")
                // iOS reports a VideoCallStatus instead of Android's sharingScreen / sessionInBackground flags
                switch result.data {
                case .RECORDING_SCREEN:
                    self.log("Video Call: Activate screen sharing")
                case .MINIMIZED:
                    self.log("Video Call: Session still active in background")
                default:
                    break
                }
                self.onMain { self.videoResult = .ok }
            } else {
                self.log("Video Call: Error - \(result.errorType)")
                self.onMain { self.videoResult = .error }
            }
        }
    }

    func stopScreenSharing() {
        log("Video Call: Stop screen sharing")
        SDKManager.shared.stopVideoCallScreenSharing { [weak self] state in
            self?.log("Screen sharing state: \(state)")
        }
    }

    func clearLogs() {
        logs = ""
        videoResult = .pending
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
