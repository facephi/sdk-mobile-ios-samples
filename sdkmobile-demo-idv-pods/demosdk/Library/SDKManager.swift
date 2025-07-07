//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import sdk
import selphiComponent
import selphidComponent
import trackingComponent
import UIKit
import tokenizeComponent
import statusComponent


protocol SDKManagerDelegate: AnyObject {
    func log(msg: String)
}

// swiftlint:disable type_body_length
class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    private let TAG = "APP_MANAGER"
    public var mainVC: MainVMOutput!
   
    // MARK: - INIT
    init() {
        let trackingController = TrackingController(trackingError: { trackingError in
            self.log("TRACKING ERROR: \(trackingError)")
        })

        let tokenizeController = TokenizeController()
        let statusController = StatusController()
        
        if SdkConfigurationManager.onlineConfiguration {
            // AUTO License
            SDKController.shared.initSdk(
                licensingUrl: SdkConfigurationManager.LICENSING_URL,
                apiKey: SdkConfigurationManager.APIKEY_LICENSING,
                activateFlow: SdkConfigurationManager.shouldDownloadFlows,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        self.log("Automatic license correctly setted")
                    } else {
                        self.log("Error while trying to set the automatic license: \(sdkResult.errorType)")
                    }
                },
                trackingController: trackingController,
                statusController: statusController
            )
        } else {
            // MANUAL License
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                activateFlow: SdkConfigurationManager.shouldDownloadFlows,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        self.log("Manual license correctly setted")
                    } else {
                        self.log("Error while trying to set the manual license: \(sdkResult.errorType)")
                    }
                },
                trackingController: trackingController,
                statusController: statusController
            )
        }
    }
    
    public func launchFlow(customerId: String, viewController: UIViewController, selphidOutput: @escaping (SdkResult<SelphIDResult>) -> Void, selphiOutput: @escaping (SdkResult<SelphiResult>) -> Void) {
        let selphidController = SelphIDController(data: nil, output: {
            print("SelphidController output: \($0.errorType)")
            // Do whatever you want with the result
            selphidOutput($0)
        }, viewController: viewController)
        
        let selphiController = SelphiController(data: nil, output: {
            print("SelphiController output: \($0.errorType)")
            // Do whatever you want with the result
            selphiOutput($0)
        }, viewController: viewController)
        
        let controllers: [IFlowableController] = [selphidController, selphiController]
        
        let flowConfigurationData = FlowConfigurationData(
            id: SdkConfigurationManager.FLOW_ID,
            controllers: controllers,
            customerId: customerId)
        
        let flowOutput: (SdkFlowResult) -> Void = { sdkFlowResult in
            print("FlowController: STEP - \(sdkFlowResult.step)")
            print("FlowController: FLOW FINISH: \(sdkFlowResult.flowFinish)")
            print("FlowController: SDKResult: ERROR=\(sdkFlowResult.result.errorType) - DATA=\(sdkFlowResult.result.data)")
            
            switch (sdkFlowResult.result.data) {
            case (let data as SelphIDResult):
                // Do whatever you want with the result
                break
            case (let data as SelphiResult):
                // Do whatever you want with the result
                break
            default: break
            }
        }
        
        self.flowController = FlowController(flowConfigurationData: flowConfigurationData, output: flowOutput)
        
        SDKController.shared.launch(controller: self.flowController!)
    }
    
    private var flowController: FlowController?
    
    private func cancelFlow() {
        self.flowController?.cancelFlow()
    }
    
    private func nextStep() {
        self.flowController?.launchNextStep()
    }
    
    private func log(_ msg: String) {
        let totalMsg = TAG + " - " + msg
        print(totalMsg)
    }
}
