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
import termsConditionsComponent
import statusComponent

// swiftlint:disable type_body_length
class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager(
        trackingVersion: PrefManager.get(.midapi, forKey: .KEY_TRACKING_VERSION),
        locale: PrefManager.get(.en, forKey: .KEY_LOCALE))
    private var sdkData: String = ""
    private var TAG = "APP_MANAGER"
    public static var mainVC: MainVMOutput?
    
    private var videoRecordingController: VideoRecordingController?
    private var videoCallController: VideoCallController?
    
    private var flowController: FlowController?
    
    private var apiKey: String = ""
    private var licensingUrl: URL!
    private var flowId: String = SdkConfigurationManager.FLOW_ID_IDV
    private var offlineLicense: String = SdkConfigurationManager.license_IDV
    private let trackingVersion: TrackingVersion

    // MARK: - INIT
    init(trackingVersion: TrackingVersion, locale: SdkLocale) {
        self.trackingVersion = trackingVersion
        setTrackingVersion(trackingVersion: trackingVersion)

        let midapiSession = trackingVersion == .midapi
        let trackingController: TrackingController? = midapiSession
            ? nil
            : TrackingController(trackingError: { trackingError in
                self.log("TRACKING ERROR: \(trackingError)")
            }, debug: true)

        let tokenizeController = TokenizeController()
        let statusController = StatusController()
        ThemeStatusManager.setup(theme: CustomThemeStatus())

        let initOutput: (SdkResult<String>) -> Void = { sdkResult in
            if sdkResult.finishStatus == .STATUS_OK {
                self.sdkData = sdkResult.data ?? ""
                self.log(midapiSession ? "SDK MidApi iniciado correctamente" : "Licencia seteada correctamente")
            } else {
                self.log("Error init SDK: \(sdkResult.errorType)")
            }
        }

        let analyticsOutput: AnalyticsOutput = { time, component, type, info in
            self.log("Analytics: \(Date().getFormattedDate(format: "HH:mm:ss")) \(component) - \(type) - \(info)", show: false)
        }

        if SdkConfigurationManager.onlineLicensing {
            SDKController.shared.initSdk(
                licensingUrl: licensingUrl,
                apiKey: apiKey,
                locale: locale.rawValue,
                sessionVisualOptions: SdkConfigurationManager.demoSessionVisualOptions,
                output: initOutput,
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                behaviorController: nil,
                statusController: statusController,
                analyticsOutput: analyticsOutput
            )
        } else {
            SDKController.shared.initSdk(
                license: offlineLicense,
                locale: locale.rawValue,
                sessionVisualOptions: SdkConfigurationManager.demoSessionVisualOptions,
                output: initOutput,
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                behaviorController: nil,
                statusController: statusController,
                analyticsOutput: analyticsOutput
            )
        }
    }

    private var enableTrackingForOperations: Bool {
        trackingVersion != .midapi
    }
    
    private var selphiResults: [SelphiResult] = []
    public func launchFlow(customerId: String, viewController: UIViewController, output: @escaping (SdkResult<String>) -> Void, offline: Bool = false) {
        //        ThemeSelphidManager.setup(theme: CustomThemeSelphID())
        let selphidController = SelphIDController(
            data: nil,
            extractors: SelphIDExtractorProvider.makeAllExtractors(),
            output: {
                self.log("SelphidController output: \($0.errorType)")
            },
            viewController: viewController
        )
        let selphiController = SelphiController(data: nil, output: {
            self.log("SelphiController output: \($0.errorType)")
        }, viewController: viewController)
        let startVideoRecordingController = VideoRecordingController(data: nil, viewController: viewController, output: {
            self.log("StartVideoRecordingController output: \($0.errorType)")
        })
        let stopVideoRecordingController = StopVideoRecordingController(videoRecordingController: startVideoRecordingController, output: {
            self.log("StopVideoRecordingController output: \($0.errorType)")
        })
        self.videoRecordingController = startVideoRecordingController
        
        let nfcController = NfcController(data: nil, viewController: viewController, output: {
            self.log("NfcController output: \($0.errorType)")
        })
        let phingersController = PhingersController(data: nil, output: {
            self.log("phingersReaderController output: \($0.errorType)")
        }, viewController: viewController)
        
        let videoIdController = VideoIdController(data: nil, output: {
            self.log("videoIdController output: \($0.errorType)")
        }, viewController: viewController)
        let voiceController = VoiceController(data: nil, output: {
            self.log("voiceController output: \($0.errorType)")
        }, viewController: viewController)
        
        let qrReaderController = QrReaderController(data: nil, output: {
            self.log("qrReaderController output: \($0.errorType)")
        }, viewController: viewController)
        let videoCallController = VideoCallController(data: nil, extensionIdentifier: "com.facephi.sdk.demo.videoRecording", output: {
            self.log("videoCallController output: \($0.errorType)")
        }, viewController: viewController)
        self.videoCallController = videoCallController
        
        let externalStepController = ExternalStepController(output: {
            self.log("externalStepController output")
        })
        
        let controllers: [IFlowableController] =
        [selphidController, selphiController, startVideoRecordingController, stopVideoRecordingController, nfcController, phingersController, videoIdController, voiceController, qrReaderController, videoCallController, externalStepController]
        
        // PRO - f764dd36-8249-48a9-a7fd-9ddca9bfea88
        // PRO - 7359277b-505e-40df-8e52-a6f0c37cd40b -> selphid, externo, phacturas
        // 910099cf-a988-4b47-8ae7-9d7d063d9472 -> Phingers, External and VideoID
        
        let flowId = PrefManager.get(String.self, forKey: .KEY_FLOW_ID)
        let flowConfigurationData = FlowConfigurationData(
            id: flowId?.isEmpty == false ? flowId! : self.flowId,
            controllers: controllers,
            customerId: customerId)
        
        let flowOutput: (SdkFlowResult) -> Void = { sdkFlowResult in
            self.log("FlowController: STEP - \(sdkFlowResult.step)\nFlowController: FLOW FINISH: \(sdkFlowResult.flowFinish)\nFlowController: SDKResult: ERROR=\(sdkFlowResult.result.errorType)")
            
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
    
    func cancelLaunch() {
        self.log("CANCEL LAUNCH")
        SDKController.shared.cancelLaunch()
        self.flowController = nil
    }

    func enableVolumeUpCancelLaunch() {
        CancelLaunchVolumeTrigger.shared.enable(
            onLog: { self.log($0) },
            onCancelLaunch: { self.cancelLaunch() }
        )
    }

    func disableVolumeUpCancelLaunch() {
        CancelLaunchVolumeTrigger.shared.disable(onLog: { self.log($0) })
    }
    
    public func launchSelphi(setTracking: Bool, viewController: UIViewController, selphiConfigurationData: SelphiConfigurationData, output: @escaping (SdkResult<SelphiResult>) -> Void) {
        self.log("LAUNCH SELPHI")

        let customViews = SdkConfigurationManager.useDemoKmpCustomCameraOverlay
            ? DemoKmpCustomViewsFactory.makeSelphiCustomViews()
            : nil
        let controller = SelphiController(
            data: selphiConfigurationData,
            customViews: customViews,
            output: output,
            viewController: viewController
        )
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
        self.log("LAUNCH SIGNATURE SELPHI")

        let controller = SignatureSelphiController(data: selphiConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchSelphId(setTracking: Bool, viewController: UIViewController, selphIDConfigurationData: SelphIDConfigurationData, output: @escaping (SdkResult<SelphIDResult>) -> Void) {
        self.log("LAUNCH SELPHID")
        
        let controller = SelphIDController(
            data: selphIDConfigurationData,
            extractors: SelphIDExtractorProvider.makeAllExtractors(),
            output: output,
            viewController: viewController
        )
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchPhingers(setTracking: Bool, viewController: UIViewController, phingersConfigurationData: PhingersConfigurationData, output: @escaping (SdkResult<PhingersResult>) -> Void) {
        self.log("LAUNCH PHINGERS")

        let customViews = SdkConfigurationManager.useDemoKmpCustomCameraOverlay
            ? DemoKmpCustomViewsFactory.makePhingersCustomViews()
            : nil
        let controller = PhingersController(
            data: phingersConfigurationData,
            customViews: customViews,
            output: output,
            viewController: viewController
        )
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchNfc(setTracking: Bool, viewController: UIViewController, nfcConfigurationData: NfcConfigurationData, output: @escaping (SdkResult<NfcResult>) -> Void) {
        self.log("LAUNCH NFC")
        
        let controller = NfcController(data: nfcConfigurationData, viewController: viewController, output: output, stateDelegate: nil)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchQrGenerator(setTracking: Bool, viewController: UIViewController, qrGeneratorConfigurationData: QrGeneratorConfigurationData, output: @escaping (SdkResult<UIImage>) -> Void) {
        self.log("LAUNCH QR GENERATOR")
        let controller = QrGeneratorController(data: qrGeneratorConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchQrReader(setTracking: Bool, viewController: UIViewController, qrReaderConfigurationData: QrCaptureConfigurationData, output: @escaping (SdkResult<QrResult>) -> Void) {
        self.log("LAUNCH QR READER")
        
        let controller = QrReaderController(data: qrReaderConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchCaptureCUE(setTracking: Bool, viewController: UIViewController, fileUploaderConfigurationData: FileUploaderConfigurationData, output: @escaping (SdkResult<FileUploaderResult>) -> Void) {
        self.log("LAUNCH DOCUMENT CAPTURE")

        let controller = FileUploaderController(data: fileUploaderConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }

    public func launchTermsConditions(setTracking: Bool, viewController: UIViewController, termsConditionsConfigurationData: TermsConditionsConfigurationData, output: @escaping (SdkResult<TermsConditionsResult>) -> Void) {
        self.log("LAUNCH TERMS CONDITIONS")
        
        let controller = TermsConditionsController(data: termsConditionsConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchExtradata() -> SdkResult<String> {
        self.log("LAUNCH EXTRADATA")
        return SDKController.shared.getExtraData()
//    public func launchExtraData(output: @escaping (SdkResult<String>) -> Void) {
//        let extraDataController = ExtraDataController(output: output)
//        SDKController.shared.launch(controller: extraDataController)
    }
    
    public func launchVideoCall(data: VideoCallConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VideoCallStatus>) -> Void) {
        self.log("LAUNCH VIDEO CALL")
        
        let videocallController = VideoCallController(data: data, extensionIdentifier: "com.facephi.sdk.demo.videoRecording", output: output, viewController: viewController)
        self.videoCallController = videocallController
        SDKController.shared.launch(controller: videocallController)
    }
    
    public func hangoutVideoCall() {
        self.videoCallController?.hangout()
    }
    
    public func launchVideoId(data: VideoIDConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VideoIDResult>) -> Void) {
        self.log("LAUNCH VIDEO ID")
        
        let videoidController = VideoIdController(data: data, output: output, viewController: viewController)
        SDKController.shared.launch(controller: videoidController)
    }
    
    public func launchSignatureVideoId(data: VideoIDConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VideoIDResult>) -> Void) {
        self.log("LAUNCH SIGNATURE VIDEO ID")
        
        let videoidController = SignatureVideoIdController(data: data, output: output, viewController: viewController)
        SDKController.shared.launch(controller: videoidController)
    }
        
    public func launchVoiceId(data: VoiceConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VoiceResult>) -> Void) {
        self.log("LAUNCH VOICE ID")
        
        let controller = VoiceController(
            data: data,
            output: { sdkResult in
                let voiceIdSdkResult = SdkResult(finishStatus: sdkResult.finishStatus, errorType: sdkResult.errorType, data: sdkResult.data)
                output(voiceIdSdkResult)
            }, viewController: viewController)
        SDKController.shared.launch(controller: controller)
    }
    
    public func launchVideoRecording(viewController: UIViewController, configuration: VideoRecordingConfigurationData) {
        let videoRecordingController = VideoRecordingController(data: configuration, extensionIdentifier: "com.facephi.sdk.demo.videoRecording", viewController: viewController, output: {
            self.log("videoRecordingController output: \($0.errorType)")
        })
        
        SDKController.shared.launch(controller: videoRecordingController)
        self.videoRecordingController = videoRecordingController
    }
    
    public func stopVideoRecording() {
        self.log("VIDEO RECORDING STOPPED")

        self.videoRecordingController?.stopVideoRecording()
        self.videoRecordingController = nil
    }
    
    public func launchVoiceEnrollment(audios: [String], baseVoiceUrl: String, methodAuth: String, output: @escaping (SdkResult<VoiceEnrollmentResult>) -> Void) {
        self.log("LAUNCH VOICE MATCHING")
        let voiceEnrollmentController = VoiceEnrollmentController(audios: audios, baseVoiceUrl: baseVoiceUrl, methodAuth: methodAuth, output: output)
        SDKController.shared.launchMethod(controller: voiceEnrollmentController)
    }
    
    public func launchVoiceMatching(audio: String, template: String, liveness_threshold: Double, baseVoiceUrl: String, methodAuth: String, output: @escaping (String) -> Void) {
        self.log("LAUNCH VOICE MATCHING")
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
        self.log("newOperation - start, device, coordinates, customerId - \(customerId)")

        SDKController.shared.newOperation(
            operationType: operationType,
            customerId: customerId,
            enableTracking: enableTrackingForOperations,
            output: output
        )
    }
    
    public func closeSession() {
        self.log("Closed Session: \(SDKController.shared.getSessionId())\nCreated new Session: \(SDKController.shared.closeSession().data)")
    }
    
    private func log(_ msg: String, show: Bool = true) {
        let totalMsg = TAG + " - " + msg
        if show {
            SDKManager.mainVC?.show(msg: totalMsg)
        }
        print(totalMsg)
    }
    
    public func getExtraDataResult() -> SdkResult<String> {
        log("LAUNCH EXTRADATA")
        return SDKController.shared.getExtraData()
    }
    
    public func launchGenerateRawTemplate(data: Data) {
        self.log("LAUNCH GENERATE RAW TEMPLATE")
        
        let controller = RawTemplateController(
            base64: data.base64EncodedString(),
            output: { sdkResult in
                    guard let result = sdkResult.data else {return}
                self.log(result)
            })
        SDKController.shared.launchMethod(controller: controller)
    }
    
    func setCustomerId(customerId: String) {
        SDKController.shared.setCustomerId(customerId: customerId)
    }
    
    func setTrackingVersion(trackingVersion: TrackingVersion) {
        switch trackingVersion {
        case .midapi:
            TAG = "MIDAPI"
            apiKey = SdkConfigurationManager.APIKEY_LICENSING_V2_MIDAPI
            licensingUrl = SdkConfigurationManager.LICENSING_URL_STG
            flowId = SdkConfigurationManager.FLOW_ID_V2_STG
            offlineLicense = SdkConfigurationManager.license_MIDAPI
        case .IDV:
            TAG = "IDV"
            apiKey = SdkConfigurationManager.APIKEY_LICENSING_IDV_STG
            licensingUrl = SdkConfigurationManager.LICENSING_URL_IDV_STG
            flowId = SdkConfigurationManager.FLOW_ID_IDV
            offlineLicense = SdkConfigurationManager.license_IDV
        case .v2_LIVEKIT:
            TAG = "V2_LIVEKIT"
            apiKey = SdkConfigurationManager.APIKEY_LICENSING_V2_LIVEKIT
            licensingUrl = SdkConfigurationManager.LICENSING_URL_STG
            flowId = SdkConfigurationManager.FLOW_ID_V2_STG
            offlineLicense = SdkConfigurationManager.licenseSTG
        case .v2_STG:
            TAG = "V2_STG"
            apiKey = SdkConfigurationManager.APIKEY_LICENSING_V2_STG
            licensingUrl = SdkConfigurationManager.LICENSING_URL_STG
            flowId = SdkConfigurationManager.FLOW_ID_V2_STG
            offlineLicense = SdkConfigurationManager.licenseSTG
        }
    }
}
