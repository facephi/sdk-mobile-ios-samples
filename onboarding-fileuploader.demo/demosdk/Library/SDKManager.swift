//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import UIKit

import captureComponent
import sdk
import selphiComponent
import selphidComponent
import trackingComponent
import videoRecordingComponent
import tokenizeComponent
import statusComponent

protocol SDKManagerDelegate: AnyObject {
    func log(msg: String)
}

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager(
        trackingVersion: PrefManager.get(TrackingVersion.self, forKey: .KEY_TRACKING_VERSION),
        locale: PrefManager.get(SdkLocale.self, forKey: .KEY_LOCALE) ?? SdkLocale.es
    )
    public var mainVC: MainVMOutput!
    
    private var videoRecordingController: VideoRecordingController?
    private var flowController: FlowController?
    private var flowId: String = SdkConfigurationManager.FLOW_ID
    
    private var documentValidationService: DocumentValidationServiceProtocol?
    private var operationId: String = ""
    private var tokenFaceImage: String = ""
    private var bestImageToken: String = ""
    private var tokenOcr: String = ""
    private var frontDocumentImage: String = ""
    private var backDocumentImage: String = ""
    private var requestedScanReference: String = ""

    // MARK: - INIT
    init(trackingVersion: TrackingVersion?, locale: SdkLocale) {
        let trackingController = TrackingController(trackingError: { trackingError in
            self.log("TRACKING ERROR: \(trackingError)")
        })
        
        let tokenizeController = TokenizeController()
        let statusController = StatusController()
        ThemeStatusManager.setup(theme: CustomThemeStatus())
        SdkConfigurationManager.setTrackingVersion(trackingVersion: trackingVersion)

        SDKController.shared.initSdk(
            licensingUrl: SdkConfigurationManager.LICENSING_URL,
            apiKey: SdkConfigurationManager.APIKEY_LICENSING,
            locale: locale.rawValue,
            output: { sdkResult in
                if sdkResult.finishStatus == .STATUS_OK {
                    self.log("License correctly fetched")
                } else {
                    self.log("An error occured while fetching the license: \(sdkResult.errorType)")
                }
            },
            trackingController: trackingController,
            tokenizeController: tokenizeController,
            behaviorController: nil,
            statusController: statusController,
            analyticsOutput: { time, component, type, info  in
                self.log("Analytics: \(Date().getFormattedDate(format: "HH:mm:ss")) \(component) - \(type) - \(info)")
            }
        )
    }
    
    public func newOperation(operationType: OperationType, customerId: String, output: @escaping (SdkResult<String>) -> Void) {
        log("newOperation - start, device, coordinates, customerId - \(customerId)")
        
        let steps: [Step] = [.OTHER("VIDEO_RECORDING_WIDGET"), .SELPHID_WIDGET, .SELPHI_WIDGET, .CAPTURE_WIDGET]
        SDKController.shared.newOperation(operationType: operationType, customerId: customerId, steps: steps, output: output)
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
    
    public func launchSelphId(setTracking: Bool, viewController: UIViewController, selphIDConfigurationData: SelphIDConfigurationData, output: @escaping (SdkResult<SelphIDResult>) -> Void) {
        log("LAUNCH SELPHID")
        
        let controller = SelphIDController(data: selphIDConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func launchFileUploader(setTracking: Bool, viewController: UIViewController, fileUploaderConfigurationData: FileUploaderConfigurationData, output: @escaping (SdkResult<FileUploaderResult>) -> Void) {
        log("LAUNCH DOCUMENT CAPTURE")

        let controller = FileUploaderController(data: fileUploaderConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func getExtraDataResult() -> SdkResult<String> {
        log("LAUNCH EXTRADATA")
        return SDKController.shared.getExtraData()
    }
    
    public func launchVideoRecording(viewController: UIViewController) {
        let data = VideoRecordingConfigurationData()
        let videoRecordingController = VideoRecordingController(data: data, extensionIdentifier: nil, viewController: viewController, output: {
            self.log("videoRecordingController output: \($0.errorType)")
        })
        
        SDKController.shared.launch(controller: videoRecordingController)
        self.videoRecordingController = videoRecordingController
    }
    
    public func stopVideoRecording() {
        self.videoRecordingController?.stopVideoRecording()
    }
    
    public func launchFlow(customerId: String, viewController: UIViewController, output: @escaping (SdkResult<String>) -> Void) {
//        ThemeSelphidManager.setup(theme: CustomThemeSelphID())
        
        let selphidController = SelphIDController(data: nil, output: {
            self.log("SelphidController output: \($0.errorType)")
        }, viewController: viewController)
        
        let selphiController = SelphiController(data: nil, output: {
            self.log("SelphiController output: \($0.errorType)")
        }, viewController: viewController)
        
        let fileUploaderController = FileUploaderController(data: nil, output: {
            self.log("FileUploaderController output: \($0.errorType)")
        },viewController: viewController)
        
        let startVideoRecordingController = VideoRecordingController(data: nil, extensionIdentifier: nil, viewController: viewController, output: {
            self.log("StartVideoRecordingController output: \($0.errorType)")
        })
        let stopVideoRecordingController = StopVideoRecordingController(videoRecordingController: startVideoRecordingController, output: {
            self.log("StopVideoRecordingController output: \($0.errorType)")
        })
        
        self.videoRecordingController = startVideoRecordingController
        
        let externalStepController = ExternalStepController(output: {
            self.log("ExternalStepController output")
        })
        
        let controllers: [IFlowableController] =
        [selphidController, selphiController, fileUploaderController, startVideoRecordingController, stopVideoRecordingController, externalStepController]
        
        let flowId = PrefManager.get(String.self, forKey: .KEY_FLOW_ID)
        let flowConfigurationData = FlowConfigurationData(
            id: flowId?.isEmpty == false ? flowId! : self.flowId,
            controllers: controllers,
            customerId: customerId)
        
        let flowOutput: (SdkFlowResult) -> Void = { sdkFlowResult in
            self.log("FlowController: STEP - \(sdkFlowResult.step)")
            self.log("FlowController: FLOW FINISH: \(sdkFlowResult.flowFinish)")
            self.log("FlowController: SDKResult: ERROR=\(sdkFlowResult.result.errorType)")
            
            switch (sdkFlowResult.result.data) {
            case (let data as SelphIDResult):
                break
            case (let data as SelphiResult):
                break
            case (let data as FileUploaderResult):
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
    
    public func closeSession() {
        log("Closed Session: \(SDKController.shared.getSessionId())\nCreated new Session: \(SDKController.shared.closeSession().data)")
    }
    
    private func log(_ msg: String) {
        let totalMsg = SdkConfigurationManager.trackingVersionTag + " - " + msg
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
                self.log("Template: \(sdkResult.data)")
            })
        SDKController.shared.launchMethod(controller: controller)
    }
    
    func setCustomerId(customerId: String) {
        SDKController.shared.setCustomerId(customerId: customerId)
    }
}
