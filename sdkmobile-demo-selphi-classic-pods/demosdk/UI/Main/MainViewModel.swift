//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt (DemoSelphiClassic).
//

import CoreLocation
import sdk
import selphiClassicComponent
import SwiftUI

final class MainViewModel: ObservableObject {
    @Published private(set) var logs = ""
    @Published private(set) var newOperationClicked = false
    @Published var selphiResult: UIComponentResult = .pending

    @Published private var selphiBestImage: UIImage?
    private(set) var selphiBestImageTokenized: String?

    let version = sdk.Constants.libraryPackageVersion

    private let locationManager = CLLocationManager()
    private var initialized = false

    var images: [UIImage] {
        [selphiBestImage].compactMap { $0 }
    }

    func initSdk() {
        guard !initialized else { return }
        initialized = true

        locationManager.requestWhenInUseAuthorization()

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

    func launchSelphi(options: SelphiLaunchOptions) {
        guard let viewController = UIApplication.topViewController else { return }

        let configuration = SdkConfigurationManager.selphiConfiguration(
            showTutorial: options.showTutorial,
            showPreviousTip: options.showPreviousTip,
            showDiagnostic: options.showDiagnostic
        )

        SDKManager.shared.launchSelphi(
            viewController: viewController,
            selphiConfigurationData: configuration
        ) { [weak self] result in
            guard let self else { return }
            if result.errorType == .NO_ERROR {
                self.log("Selphi: OK")
                self.onMain {
                    if let data = result.data?.bestImageData {
                        self.selphiBestImage = UIImage(data: data)
                    }
                    if let tokenized = result.data?.bestImageTokenized, !tokenized.isEmpty {
                        self.selphiBestImageTokenized = tokenized
                    }
                    self.selphiResult = .ok
                }
            } else {
                self.log("Selphi: Error - \(result.errorType)")
                self.onMain { self.selphiResult = .error }
            }
        }
    }

    func clearLogs() {
        logs = ""
        selphiBestImage = nil
        selphiBestImageTokenized = nil
        selphiResult = .pending
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
