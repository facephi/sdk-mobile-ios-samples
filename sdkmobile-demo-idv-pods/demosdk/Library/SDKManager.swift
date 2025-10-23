//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//
import Foundation
import UIKit
import core
import selphiComponent
import selphidComponent
import sdk
import statusComponent
import tokenizeComponent
import trackingComponent
import videoRecordingComponent

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    private var videoRecordingController: VideoRecordingController?
    private var flowController: FlowController?
    private var TAG = "IDV_APP"
    static var delegate: SdkManagerDelegate?

    // MARK: - INIT
    init() {
        initializeSDK()
    }
    
    func initializeSDK() {
        let trackingController = TrackingController(trackingError: { trackingError in
            self.log("TRACKING ERROR: \(trackingError)")
        })
        
        let tokenizeController = TokenizeController()
        let statusController = StatusController()
        
        if SdkConfigurationManager.onlineLicensing {
            SDKController.shared.initSdk(
                licensingUrl: SdkConfigurationManager.LICENSING_URL,
                apiKey: SdkConfigurationManager.APIKEY_LICENSING_IDV,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            SDKManager.delegate?.setAvailableFlows(flows: FlowController.getFlowIntegrationData())
                        })
                        self.log("Licencia automática seteada correctamente")
                    } else {
                        self.log("Ha ocurrido un error al intentar obtener la licencia: \(sdkResult.errorType)")
                    }
                },
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                statusController: statusController,
                analyticsOutput: { time, component, type, info  in
                    self.log("Analytics: \(Date().getFormattedDate(format: "HH:mm:ss")) \(component) - \(type) - \(info)")
                }
            )
        } else {
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                            SDKManager.delegate?.setAvailableFlows(flows: FlowController.getFlowIntegrationData())
                        })
                        self.log("Licencia manual seteada correctamente")
                    } else {
                        self.log("La licencia manual no es correcta")
                    }
                },
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                statusController: statusController,
                analyticsOutput: { time, component, type, info  in
                    self.log("Analytics: \(Date().getFormattedDate(format: "HH:mm:ss")) \(component) - \(type) - \(info)")
                }
            )
        }
    }
    
    public func launchFlow(flowId: String, viewController: UIViewController, output: @escaping (SdkFlowResult) -> Void) {
        let selphidController = SelphIDController(data: nil, output: {
            print("SelphidController output: \($0.errorType)")
        }, viewController: viewController)
        
        let selphiController = SelphiController(data: nil, output: {
            print("SelphiController output: \($0.errorType)")
        }, viewController: viewController)
        
        let videoRecordingController = VideoRecordingController(extensionIdentifier: "com.facephi.sdk.demo.videoRecording", viewController: viewController, output: {
            print("videoRecordingController output: \($0.errorType)")
        })
        self.videoRecordingController = videoRecordingController
        
        let stopVideoRecordingController = StopVideoRecordingController(videoRecordingController: videoRecordingController, output: {
            print("stopVideoRecordingController output: \($0.errorType)")
        })
        
        let controllers: [IFlowableController] =
        [selphidController, selphiController, videoRecordingController, stopVideoRecordingController]
        
        let flowConfigurationData = FlowConfigurationData(
            id: flowId,
            controllers: controllers,
            customerId: SdkConfigurationManager.customerId)
        
        let flowController = SdkConfigurationManager.onlineFlow ? FlowController(flowConfigurationData: flowConfigurationData, output: output): FlowOfflineController(flowConfigurationData: flowConfigurationData, output: output)
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
    
    private func log(_ msg: String) {
        let totalMsg = TAG + " - " + msg
        print(totalMsg)
        SDKManager.delegate?.show(msg: msg)
    }
}
