//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import UIKit

import nfcComponent
import captureComponent
import phingersTFComponent
import sdk
import selphiComponent
import selphidComponent
import trackingComponent
import videocallComponent
import videoidComponent
import videoRecordingComponent
import tokenizeComponent
import voiceIDComponent
import statusComponent

protocol SDKManagerDelegate: AnyObject {
    func log(msg: String)
}

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager(
        locale: PrefManager.get(SdkLocale.self, forKey: .KEY_LOCALE) ?? SdkLocale.es
    )
    private var sdkData: String = ""
    private var TAG = "APP_MANAGER"
    public var mainVC: MainVMOutput!
    
    private var videoRecordingController: VideoRecordingController?
    private var videoCallController: VideoCallController?
    
    private var flowController: FlowController?
    private var flowId: String = SdkConfigurationManager.FLOW_ID
    
    // MARK: - INIT
    init(locale: SdkLocale) {
        let trackingController = TrackingController(trackingError: { trackingError in
            self.log("TRACKING ERROR: \(trackingError)")
        })
        
        let tokenizeController = TokenizeController()
        let statusController = StatusController()
        ThemeStatusManager.setup(theme: CustomThemeStatus())
        
        SDKController.shared.initSdk(
            licensingUrl: SdkConfigurationManager.LICENSING_URL,
            apiKey: SdkConfigurationManager.APIKEY_LICENSING,
            locale: locale.rawValue,
            output: { sdkResult in
                if sdkResult.finishStatus == .STATUS_OK {
                    self.sdkData = sdkResult.data ?? ""
                    self.log("Licencia automática seteada correctamente")
                } else {
                    self.log("Ha ocurrido un error al intentar obtener la licencia: \(sdkResult.errorType)")
                }
            },
            trackingController: trackingController,
            tokenizeController: tokenizeController, // review - remove
            behaviorController: nil,
            statusController: statusController,
            analyticsOutput: { time, component, type, info  in
                self.log("Analytics: \(Date().getFormattedDate(format: "HH:mm:ss")) \(component) - \(type) - \(info)")
            }
        )
    }
    
    private var selphiResults: [SelphiResult] = []
    public func launchFlow(customerId: String, viewController: UIViewController, output: @escaping (SdkResult<String>) -> Void) {
        //        ThemeSelphidManager.setup(theme: CustomThemeSelphID())
        let selphidController = SelphIDController(data: nil, output: {
            print("SelphidController output: \($0.errorType)")
        }, viewController: viewController)
        let selphiController = SelphiController(data: nil, output: {
            print("SelphiController output: \($0.errorType)")
        }, viewController: viewController)
        let startVideoRecordingController = VideoRecordingController(data: nil, extensionIdentifier: "com.facephi.sdk.demo.videoRecording", viewController: viewController, output: {
            print("StartVideoRecordingController output: \($0.errorType)")
        })
        let stopVideoRecordingController = StopVideoRecordingController(videoRecordingController: startVideoRecordingController, output: {
            print("StopVideoRecordingController output: \($0.errorType)")
        })
        self.videoRecordingController = startVideoRecordingController
        
        let nfcController = NfcController(data: nil, viewController: viewController, output: {
            print("NfcController output: \($0.errorType)")
        })
        let phingersController = PhingersController(data: nil, output: {
            print("phingersReaderController output: \($0.errorType)")
        }, viewController: viewController)
        
        
        let videoIdController = VideoIdController(data: nil, output: {
            print("videoIdController output: \($0.errorType)")
        }, viewController: viewController)
        let voiceController = VoiceController(data: nil, output: {
            print("invoiceReaderController output: \($0.errorType)")
        }, viewController: viewController)
        
        let qrReaderController = QrReaderController(data: nil, output: {
            print("qrReaderController output: \($0.errorType)")
        }, viewController: viewController)
        let invoiceReaderController = InvoiceReaderController(data: nil, output: {
            print("invoiceReaderController output: \($0.errorType)")
        }, viewController: viewController)
        let videoCallController = VideoCallController(data: nil, extensionIdentifier: "com.facephi.sdk.demo.videoRecording", output: {
            print("videoCallController output: \($0.errorType)")
        }, viewController: viewController)
        self.videoCallController = videoCallController
        
        let externalStepController = ExternalStepController(output: {
            print("externalStepController output")
        })
        
        let controllers: [IFlowableController] =
        [selphidController, selphiController, startVideoRecordingController, stopVideoRecordingController, nfcController, phingersController, videoIdController, voiceController, qrReaderController, invoiceReaderController, videoCallController, externalStepController]
        
        let flowId = PrefManager.get(String.self, forKey: .KEY_FLOW_ID)
        let flowConfigurationData = FlowConfigurationData(
            id: flowId?.isEmpty == false ? flowId! : self.flowId,
            controllers: controllers,
            customerId: customerId)
        
        let flowOutput: (SdkFlowResult) -> Void = { sdkFlowResult in
            print("FlowController: STEP - \(sdkFlowResult.step)")
            print("FlowController: FLOW FINISH: \(sdkFlowResult.flowFinish)")
            print("FlowController: SDKResult: ERROR=\(sdkFlowResult.result.errorType)")
            
            switch (sdkFlowResult.result.data) {
            case (let data as SelphIDResult):
                break
            case (let data as SelphiResult):
                break
            default: break
            }
        }
        
        let flowController = FlowController(flowConfigurationData: flowConfigurationData, output: flowOutput)
        
        self.flowController = flowController
        SDKController.shared.launch(controller: flowController)
    }
    
    func flowNextStep() {
        self.flowController?.launchNextStep()
    }
    
    func cancelFlow() {
        self.flowController?.cancelFlow()
        self.flowController = nil
    }
    
    public func launchSelphi(setTracking: Bool, viewController: UIViewController, selphiConfigurationData: SelphiConfigurationData, output: @escaping (SdkResult<SelphiResult>) -> Void) {
        log("LAUNCH SELPHI")

        let controller = SelphiController(data: selphiConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchSignatureSelphi(setTracking: Bool, 
                                      viewController: UIViewController,
                                      selphiConfigurationData: SelphiConfigurationData,
                                      output: @escaping (SdkResult<SelphiResult>) -> Void) {
        log("LAUNCH SIGNATURE SELPHI")

        let controller = SignatureSelphiController(data: selphiConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchSelphId(setTracking: Bool, viewController: UIViewController, selphIDConfigurationData: SelphIDConfigurationData, output: @escaping (SdkResult<SelphIDResult>) -> Void) {
        log("LAUNCH SELPHID")
        
        let controller = SelphIDController(data: selphIDConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchPhingers(setTracking: Bool, viewController: UIViewController, phingersConfigurationData: PhingersConfigurationData, output: @escaping (SdkResult<PhingersResult>) -> Void) {
        log("LAUNCH PHINGERS")
        
        let controller = PhingersController(data: phingersConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchNfc(setTracking: Bool, viewController: UIViewController, nfcConfigurationData: NfcConfigurationData, output: @escaping (SdkResult<NfcResult>) -> Void) {
        log("LAUNCH NFC")
        
        let controller = NfcController(data: nfcConfigurationData, viewController: viewController, output: output, stateDelegate: nil)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchQrGenerator(setTracking: Bool, viewController: UIViewController, qrGeneratorConfigurationData: QrGeneratorConfigurationData, output: @escaping (SdkResult<UIImage>) -> Void) {
        log("LAUNCH QR GENERATOR")
        let controller = QrGeneratorController(data: qrGeneratorConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchQrReader(setTracking: Bool, viewController: UIViewController, qrReaderConfigurationData: QrCaptureConfigurationData, output: @escaping (SdkResult<String>) -> Void) {
        log("LAUNCH QR READER")
        
        let controller = QrReaderController(data: qrReaderConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    // swiftlint:disable all
    public func launchPhacturas(setTracking: Bool, viewController: UIViewController, invoiceCaptureConfigurationData: InvoiceCaptureConfigurationData, output: @escaping (SdkResult<InvoiceResult>) -> Void) {
        log("LAUNCH INVOICE")

        let controller = InvoiceReaderController(data: invoiceCaptureConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchFileUploader(setTracking: Bool, viewController: UIViewController, fileUploaderConfigurationData: FileUploaderConfigurationData, output: @escaping (SdkResult<FileUploaderResult>) -> Void) {
        log("LAUNCH FILE UPLOADER")

        let controller = FileUploaderController(data: fileUploaderConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchExtradata() -> SdkResult<String> {
        log("LAUNCH EXTRADATA")
        return SDKController.shared.getExtraData()
    }
    
    public func launchVideoCall(data: VideoCallConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VideoCallStatus>) -> Void) {
        log("LAUNCH VIDEO CALL")
        
        let videocallController = VideoCallController(data: data, extensionIdentifier: "com.facephi.sdk.demo.videoRecording", output: output, viewController: viewController)
        self.videoCallController = videocallController
        SDKController.shared.launch(controller: videocallController)
    }
    
    public func hangoutVideoCall() {
        self.videoCallController?.hangout()
    }
    
    public func launchGallery(data: PhotoFromGalleryConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<InvoiceResult>) -> Void) {
        log("LAUNCH GALLERY")
        
        let galleryController = PhotoFromGalleryController(data: data, output: output, viewController: viewController)
        SDKController.shared.launch(controller: galleryController)
    }
    
    public func launchVideoId(data: VideoIDConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VideoIDResult>) -> Void) {
        log("LAUNCH VIDEO ID")
        
        let videoidController = VideoIdController(data: data, output: output, viewController: viewController)
        SDKController.shared.launch(controller: videoidController)
    }
    
    public func launchSignatureVideoId(data: VideoIDConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VideoIDResult>) -> Void) {
        log("LAUNCH VIDEO ID")
        
        let videoidController = SignatureVideoIdController(data: data, output: output, viewController: viewController)
        SDKController.shared.launch(controller: videoidController)
    }
        
    public func launchVoiceId(data: VoiceConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VoiceResult>) -> Void) {
        log("LAUNCH VOICE ID")
        
        let controller = VoiceController(
            data: data,
            output: { sdkResult in
                let voiceIdSdkResult = SdkResult(finishStatus: sdkResult.finishStatus, errorType: sdkResult.errorType, data: sdkResult.data)
                output(voiceIdSdkResult)
            }, viewController: viewController)
        SDKController.shared.launch(controller: controller)
    }
    
    public func launchVideoRecording(viewController: UIViewController) {
        let data = VideoRecordingConfigurationData()
        let videoRecordingController = VideoRecordingController(data: data, extensionIdentifier: "com.facephi.sdk.demo.videoRecording", viewController: viewController, output: {
            print("videoRecordingController output: \($0.errorType)")
        })
        
        SDKController.shared.launch(controller: videoRecordingController)
        self.videoRecordingController = videoRecordingController
    }
    
    public func stopVideoRecording() {
        self.videoRecordingController?.stopVideoRecording()
    }
    
    public func launchCheckLiveness(bestImage: String, baseUrl: String, methodPassiveLivenesTracking: String, param: String, callback: @escaping (String) -> Void) {
        
        var result = " "
        let extraDataResult = SDKController.shared.getExtraData()
        
        guard extraDataResult.finishStatus == .STATUS_OK,
              let data = extraDataResult.data else {
            callback("LAUNCH CHECK LIVENESS -> KO\nFAILED TO CREATE EXTRADATA: \(extraDataResult.errorType)")
            return
        }
        let parameters = "{\n\"\(param)\": \"\(bestImage)\" ,\n \"extraData\": \"\(data)\"\n}"
        
        var request = URLRequest(url: URL(string: baseUrl + methodPassiveLivenesTracking)!, timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                callback(String(describing: error))
                return
            }
            print("REQUEST CHECKLIVENESS")
            result = String(data: data, encoding: .utf8)!
            callback(result)
        }
        
        task.resume()
    }
    
    public func launchMatchingFacial(faceParam1: String, faceParam2: String, baseUrl: String, methodAuth: String, param1: String, param2: String, callback: @escaping (String) -> Void) {
        
        var result = ""
        let extraDataResult = SDKController.shared.getExtraData()
        
        guard extraDataResult.finishStatus == .STATUS_OK,
              let data = extraDataResult.data else {
            callback("LAUNCH MATCHING FACIAL -> KO\nFAILED TO CREATE EXTRADATA: \(extraDataResult.errorType)")
            return
        }
        let parameters = "{\n\t\"\(param1)\": \"\(faceParam1)\",\n\"\(param2)\": \"\(faceParam2)\",\n    \"extraData\": \"\(data)\"\n}"
        
        var request = URLRequest(url: URL(string: baseUrl + methodAuth)!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                callback(String(describing: error))
                return
            }
            print("REQUEST AUTHENTICATION")
            result = String(data: data, encoding: .utf8)!
            callback(result)
        }
        task.resume()
    }
    
    public func launchVoiceEnrollment(audios: [String], baseVoiceUrl: String, methodAuth: String, output: @escaping (SdkResult<VoiceEnrollmentResult>) -> Void) {
        log("LAUNCH VOICE MATCHING")
        let voiceEnrollmentController = VoiceEnrollmentController(audios: audios, baseVoiceUrl: baseVoiceUrl, methodAuth: methodAuth, output: output)
        SDKController.shared.launchMethod(controller: voiceEnrollmentController)
    }
    
    public func launchVoiceMatching(audio: String, template: String, liveness_threshold: Double, baseVoiceUrl: String, methodAuth: String, output: @escaping (String) -> Void) {
        log("LAUNCH VOICE MATCHING")
        let voiceMatchingController = VoiceMatchingController(audio: audio,
                                                              template: template,
                                                              liveness_threshold: liveness_threshold,
                                                              baseVoiceUrl: baseVoiceUrl,
                                                              methodAuth: methodAuth,
                                                              output: { sdkResult in
            guard let matchingResult = sdkResult.data else {
                output("launchVoiceMatching failed with error: \(sdkResult.errorType)")
                return
            }
            output("launchVoiceMatching succeeded with:\n\(matchingResult)")
        })
        SDKController.shared.launchMethod(controller: voiceMatchingController)
    }
    
    public func newOperation(operationType: OperationType, customerId: String, output: @escaping (SdkResult<String>) -> Void) {
        log("newOperation - start, device, coordinates, customerId - \(customerId)")
        
        SDKController.shared.newOperation(operationType: operationType, customerId: customerId, output: output)
    }
    
    public func closeSession() {
        log("Closed Session: \(SDKController.shared.getSessionId())\nCreated new Session: \(SDKController.shared.closeSession().data)")
    }
    
    private func log(_ msg: String) {
        let totalMsg = TAG + " - " + msg
        print(totalMsg)
    }
    
    private func showSdkResult(msg: String, sdkResultDict: [String: Any?]) {
        var finalMsg = "\(msg): \n"
        for item in sdkResultDict {
            finalMsg += "\(item.key): \(item.value ?? "") \n"
        }
        
        log(finalMsg)
    }
    
    public func launchGenerateRawTemplate(data: Data) {
        log("LAUNCH GENERATE RAW TEMPLATE")
        
        let controller = RawTemplateController(
            base64: data.base64EncodedString(),
            output: { sdkResult in
                    guard let result = sdkResult.data else {return}
                print(result)
            })
        SDKController.shared.launchMethod(controller: controller)
    }
    
    func setCustomerId(customerId: String) {
        SDKController.shared.setCustomerId(customerId: customerId)
    }
}
