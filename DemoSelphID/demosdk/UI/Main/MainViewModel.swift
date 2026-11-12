//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt (DemoSelphID).
//

import CoreLocation
import sdk
import selphidComponent
import SwiftUI

final class MainViewModel: ObservableObject {
    @Published private(set) var logs = ""
    @Published private(set) var newOperationClicked = false
    @Published var selphIdResult: UIComponentResult = .pending

    @Published private var documentFace: UIImage?
    @Published private var documentFront: UIImage?
    @Published private var documentBack: UIImage?
    private(set) var documentTokenFaceImage: String?

    let version = sdk.Constants.libraryPackageVersion

    private let locationManager = CLLocationManager()
    private var initialized = false

    var images: [UIImage] {
        [documentFace, documentFront, documentBack].compactMap { $0 }
    }

    func initSdk() {
        guard !initialized else { return }
        initialized = true

        // Same as Android MainActivity (location permission request)
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

    func launchSelphId(options: SelphIDLaunchOptions) {
        guard let viewController = UIApplication.topViewController else { return }

        let configuration = SdkConfigurationManager.selphIDConfiguration(
            showTutorial: options.showTutorial,
            showPreviousTip: options.showPreviousTip,
            showDiagnostic: options.showDiagnostic,
            showDocumentSelector: options.showDocumentSelector,
            showResultAfterCapture: options.showResultAfterCapture,
            documentType: options.documentType,
            captureMode: options.captureMode.toSdkValue(),
            generateRawImages: options.generateRawImages,
            maxAttempts: options.maxAttempts
        )

        SDKManager.shared.launchSelphId(
            viewController: viewController,
            selphIDConfigurationData: configuration
        ) { [weak self] result in
            guard let self else { return }
            if result.errorType == .NO_ERROR {
                self.log("SelphID: OK")
                self.onMain {
                    if let token = result.data?.tokenFaceImage, !token.isEmpty {
                        self.documentTokenFaceImage = token
                    }
                    self.documentFace = result.data?.faceImageData.flatMap(UIImage.init(data:))
                    self.documentFront = result.data?.frontDocumentData.flatMap(UIImage.init(data:))
                    self.documentBack = result.data?.backDocumentData.flatMap(UIImage.init(data:))
                    self.selphIdResult = .ok
                }
            } else {
                self.log("SelphID: Error - \(result.errorType)")
                self.onMain { self.selphIdResult = .error }
            }
        }
    }

    func clearLogs() {
        logs = ""
        documentFace = nil
        documentFront = nil
        documentBack = nil
        documentTokenFaceImage = nil
        selphIdResult = .pending
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
