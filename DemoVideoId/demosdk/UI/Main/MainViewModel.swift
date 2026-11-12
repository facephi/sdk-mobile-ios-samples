//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt (DemoVideoId).
//

import videoidComponent
import sdk
import SwiftUI

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

    func launchVideoId(autoFace: Bool) {
        guard let viewController = UIApplication.topViewController else { return }

        SDKManager.shared.launchVideoId(
            viewController: viewController,
            videoIDConfigurationData: SdkConfigurationManager.videoIDConfiguration(autoFace: autoFace)
        ) { [weak self] result in
            guard let self else { return }
            if result.errorType == .NO_ERROR {
                self.log("Video ID: OK")
                self.onMain { self.videoResult = .ok }
            } else {
                self.log("Video ID: Error - \(result.errorType)")
                self.onMain { self.videoResult = .error }
            }
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
