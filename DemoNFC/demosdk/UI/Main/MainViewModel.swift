//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt + Images.kt (DemoNFC).
//

import nfcComponent
import sdk
import selphidComponent
import SwiftUI

final class MainViewModel: ObservableObject {
    @Published private(set) var personalData: NfcPersonalInformation?
    @Published private(set) var nfcResult: UIComponentResult = .pending

    // Images.kt
    @Published private(set) var faceImage: UIImage?
    @Published private(set) var signatureImage: UIImage?

    let version = sdk.Constants.libraryPackageVersion

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()

    // MARK: - INIT (MainActivity: initSdk -> newOperation)

    func initSdk(onFinish: @escaping (String?) -> Void) {
        SDKManager.shared.initSdk { result in
            if result.finishStatus == .STATUS_OK {
                print("APP - INIT SDK OK")
                SDKManager.shared.newOperation { result in
                    if result.errorType == .NO_ERROR {
                        print("APP - NEW OPERATION: OK")
                        Self.onMain { onFinish(nil) }
                    } else {
                        print("APP - NEW OPERATION: Error - \(result.errorType)")
                        Self.onMain { onFinish("\(result.errorType)") }
                    }
                }
            } else {
                print("APP - INIT SDK ERROR: \(result.errorType)")
                Self.onMain { onFinish("\(result.errorType)") }
            }
        }
    }

    func newOperation(debugLogs: @escaping (String) -> Void) {
        SDKManager.shared.newOperation { result in
            Self.onMain {
                if result.errorType == .NO_ERROR {
                    debugLogs("NEW OPERATION: OK")
                } else {
                    debugLogs("NEW OPERATION: Error - \(result.errorType)")
                }
            }
        }
    }

    // MARK: - SELPHID + NFC

    func launchSelphidAndNfc(
        skipPACE: Bool,
        docType: DocumentType,
        extractFace: Bool,
        extractSignature: Bool,
        showPreviousTip: Bool,
        showTutorial: Bool,
        showDiagnostic: Bool,
        readingProgressStyle: ReadingProgressStyle,
        maxAttempts: Int,
        debugLogs: @escaping (String) -> Void
    ) {
        guard let viewController = UIApplication.topViewController else { return }
        returnLogWithDate("APP: Launch SelphID", debugLogs)

        SDKManager.shared.launchSelphId(
            viewController: viewController,
            selphIDConfigurationData: SdkConfigurationManager.getSelphIdConfig(docType)
        ) { [weak self] result in
            Self.onMain {
                guard let self else { return }
                guard result.errorType == .NO_ERROR, let data = result.data else {
                    self.returnLogWithDate("SelphID: KO - \(result.errorType)", debugLogs)
                    self.nfcResult = .error
                    return
                }

                self.returnLogWithDate("SelphID: OK", debugLogs)
                debugLogs("SelphID: Issuer :\(data.personalData?["issuer"] ?? "null")")
                debugLogs("SelphID: Nationality :\(data.personalData?["nationality"] ?? "null")")
                debugLogs("SelphID: DocumentType :\(docType.rawValue)")

                let birthDate = data.getBirthDate() ?? ""
                let expirationDate = data.getExpiryDate() ?? ""
                let nfcKey = data.getNfcKey() ?? ""

                if !birthDate.isEmpty && !expirationDate.isEmpty && !nfcKey.isEmpty {
                    let configuration = SdkConfigurationManager.getNfcConfig(
                        support: nfcKey, // Num support.
                        birthDate: birthDate, // "dd/MM/yyyy"
                        expirationDate: expirationDate, // "dd/MM/yyyy"
                        showPreviousTip: showPreviousTip,
                        showTutorial: showTutorial,
                        showDiagnostic: showDiagnostic,
                        skipPACE: skipPACE,
                        extractFace: extractFace,
                        extractSignature: extractSignature,
                        docType: docType,
                        readingProgressStyle: readingProgressStyle,
                        maxAttempts: maxAttempts
                    )
                    // Wait for the SelphID view to be dismissed before presenting NFC.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.launchNfcController(nfcConfigurationData: configuration, debugLogs: debugLogs)
                    }
                } else {
                    self.nfcResult = .error
                    self.returnLogWithDate("NFC: Data from SelphID NOT ENOUGH", debugLogs)
                }
            }
        }
    }

    // MARK: - NFC

    func launchNfc(nfcConfigurationData: NfcConfigurationData, debugLogs: @escaping (String) -> Void) {
        launchNfcController(nfcConfigurationData: nfcConfigurationData, debugLogs: debugLogs)
    }

    private func launchNfcController(nfcConfigurationData: NfcConfigurationData, debugLogs: @escaping (String) -> Void) {
        guard let viewController = UIApplication.topViewController else { return }
        returnLogWithDate("APP: Launch NFC", debugLogs)
        debugLogs("NFC - Configuration: Extract Facial image :\(nfcConfigurationData.extractFacialImage)")
        debugLogs("NFC - Configuration: Extract Signature image :\(nfcConfigurationData.extractSignatureImage)")
        debugLogs("NFC - Configuration: SkipPace :\(nfcConfigurationData.skipPACE)")

        SDKManager.shared.launchNfc(
            viewController: viewController,
            nfcConfigurationData: nfcConfigurationData,
            state: { [weak self] state in
                print("APP - NFC  State: \(state)")
                Self.onMain { self?.returnLogWithDate("NFC: State: \(state)", debugLogs) }
            }
        ) { [weak self] result in
            Self.onMain {
                guard let self else { return }
                guard result.errorType == .NO_ERROR, let data = result.data else {
                    print("APP -  NFC ERROR - \(result.errorType)")
                    self.returnLogWithDate("NFC: ERROR - \(result.errorType)", debugLogs)
                    self.nfcResult = .error
                    return
                }

                print("APP -  NFC OK")
                self.returnLogWithDate("NFC finish OK", debugLogs)
                debugLogs("VALIDATIONS: \(data.nfcValidations?.toStringDictionary().description ?? "null")")
                if let type = data.nfcDocumentInformation?.type {
                    debugLogs("TYPE: \(type)")
                }
                if let issuer = data.nfcDocumentInformation?.issuer {
                    debugLogs("ISSUER: \(issuer)")
                }
                if let nationality = data.nfcPersonalInformation?.nationality {
                    debugLogs("NATIONALITY: \(nationality)")
                }

                if let facialImage = data.nfcImages?.facialImage {
                    self.faceImage = facialImage
                    debugLogs("FACIAL image extracted")
                } else {
                    debugLogs("FACIAL image NULL")
                }

                if let signatureImage = data.nfcImages?.signatureImage {
                    self.signatureImage = signatureImage
                    debugLogs("SIGNATURE image extracted")
                } else {
                    debugLogs("SIGNATURE image NULL")
                }

                self.personalData = data.nfcPersonalInformation
                self.nfcResult = .ok
            }
        }
    }

    // MARK: - TERMS AND CONDITIONS

    func launchTermsAndConditions(text: String, output: @escaping (Bool) -> Void) {
        print("APP - Launch Terms and Conditions")
        guard let viewController = UIApplication.topViewController else { return }

        SDKManager.shared.launchTermsConditions(viewController: viewController, text: text) { result in
            Self.onMain {
                if result.errorType == .NO_ERROR {
                    print("APP - TERMS ACCEPTED")
                    output(true)
                } else {
                    print("APP - TERMS ERROR - \(result.errorType)")
                    output(false)
                }
            }
        }
    }

    // MARK: - DATA

    func clearData() {
        personalData = nil
        nfcResult = .pending
        faceImage = nil
        signatureImage = nil
    }

    func returnLogWithDate(_ msg: String, _ debugLogs: (String) -> Void) {
        debugLogs("\(formatEpochMillis()) \(msg)")
    }

    func formatEpochMillis(_ date: Date = Date()) -> String {
        Self.dateFormatter.string(from: date)
    }

    private static func onMain(_ block: @escaping () -> Void) {
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
