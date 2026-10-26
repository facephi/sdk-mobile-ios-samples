//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt (DemoRecordingOnboarding).
//

import sdk
import selphiComponent
import selphidComponent
import SwiftUI

final class MainViewModel: ObservableObject {
    @Published private(set) var logs = ""
    @Published private(set) var newOperationClicked = false
    @Published var videoResult: UIComponentResult = .pending
    @Published var selphiResult: UIComponentResult = .pending
    @Published var selphIdResult: UIComponentResult = .pending

    @Published private var selphiBestImage: UIImage?
    @Published private var documentFace: UIImage?
    @Published private var documentFront: UIImage?
    @Published private var documentBack: UIImage?
    private(set) var selphiBestImageTokenized: String?
    private(set) var documentTokenFaceImage: String?

    let version = sdk.Constants.libraryPackageVersion

    private var initialized = false

    var images: [UIImage] {
        [selphiBestImage, documentFace, documentFront, documentBack].compactMap { $0 }
    }

    func initSdk() {
        guard !initialized else { return }
        initialized = true

        // Android DemoRecordingOnboarding does not ask for location permissions.
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

    func launchVideoRecording() {
        guard let viewController = UIApplication.topViewController else { return }

        SDKManager.shared.launchVideoRecording(
            viewController: viewController,
            videoRecordingConfigurationData: SdkConfigurationManager.videoRecordingConfiguration
        ) { [weak self] result in
            guard let self else { return }
            if result.errorType == .NO_ERROR {
                self.log("VIDEO_RECORDING Start: OK")
                self.onMain { self.videoResult = .ok }
            } else {
                self.log("VIDEO_RECORDING Start: ERROR Name- \(result.errorType)")
                self.onMain { self.videoResult = .error }
            }
        }
    }

    func stopVideoRecording() {
        SDKManager.shared.stopVideoRecording { [weak self] result in
            if result.errorType == .NO_ERROR {
                self?.log("VIDEO_RECORDING Stop: OK")
            } else {
                self?.log("VIDEO_RECORDING Stop: ERROR Name- \(result.errorType)")
            }
        }
    }

    func launchSelphi(options: SelphiLaunchOptions) {
        guard let viewController = UIApplication.topViewController else { return }

        let configuration = SdkConfigurationManager.selphiConfiguration(
            showTutorial: options.showTutorial,
            showPreviousTip: options.showPreviousTip,
            showDiagnostic: options.showDiagnostic,
            cameraPreferred: options.cameraPreferred,
            livenessMode: options.livenessMode.toSdkValue(
                moveSuccessfulAttempts: options.moveSuccessfulAttempts,
                moveFailedAttempts: options.moveFailedAttempts
            ),
            maxAttempts: options.maxAttempts,
            iadEnabled: options.iadEnabled
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
                    self.selphiBestImageTokenized = result.data?.bestImageTokenized
                    self.selphiResult = .ok
                }
            } else {
                self.log("Selphi: Error - \(result.errorType)")
                self.onMain { self.selphiResult = .error }
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
        selphiBestImage = nil
        selphiBestImageTokenized = nil
        documentFace = nil
        documentFront = nil
        documentBack = nil
        documentTokenFaceImage = nil
        selphiResult = .pending
        selphIdResult = .pending
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
