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
    private var sdkData: String = ""
    private let TAG = "APP_MANAGER"
    public var mainVC: MainVMOutput!
   
    // MARK: - INIT
    init() {
        let trackingController = TrackingController(trackingError: { trackingError in
            self.log("TRACKING ERROR: \(trackingError)")
        })
        trackingController.tenantIdDemo = SdkConfigurationManager.CUSTOM_TENANT_ID
        
        let tokenizeController = TokenizeController()
        let statusController = StatusController()
        if SdkConfigurationManager.onlineLicensing {
            // AUTO License
            SDKController.shared.initSdk(
                licensingUrl: SdkConfigurationManager.LICENSING_URL,
                apiKey: SdkConfigurationManager.APIKEY_LICENSING,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        self.sdkData = sdkResult.data ?? ""
                        self.log("Licencia automática seteada correctamente")
                    } else {
                        self.log("Ha ocurrido un error al intentar obtener la licencia: \(sdkResult.errorType)")
                    }
                },
                trackingController: trackingController,
                tokenizeController: tokenizeController,
                statusController: statusController
            )
        } else {
            //         MANUAL License
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        self.log("Licencia manual seteada correctamente")
                    } else {
                        self.log("La licencia manual no es correcta")
                    }
                },
                trackingController: trackingController,
                tokenizeController: tokenizeController
            )
        }
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
    
    public func launchExtradata() -> SdkResult<String> {
        SDKController.shared.getExtraData()
    }

    public func launchCheckLiveness(bestImage: String, extradata: String, baseUrl: String, methodPassiveLivenesTracking: String) -> String {
        log("LAUNCH CHECKLIVENESS")
        
        var result = " "
        let extraDataResult = SDKController.shared.getExtraData()
        
        if extraDataResult.finishStatus == .STATUS_OK,
           let data = extraDataResult.data {
            let parameters = "{\n\"image\": \"\(bestImage)\" ,\n \"extraData\": \"\(extradata)\"\n}"
            let postData = parameters.data(using: .utf8)
            
            var request = URLRequest(url: URL(string: baseUrl + methodPassiveLivenesTracking)!, timeoutInterval: Double.infinity)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                print("REQUEST CHECKLIVENESS")
                print(String(data: data, encoding: .utf8)!)
                result = String(data: data, encoding: .utf8)!
            }
            
            task.resume()
            
            return result
        } else {
            log("LAUNCH CHECK LIVENESS -> KO")
        }
        return "Not implemented"
    }
    
    public func launchCheckAuth(tokenFaceImage: String, bestImage: String, extradata: String, baseUrl: String, methodAuth: String) -> String {
        log("LAUNCH AUTHENTICATION FACIAL")
        var result = ""
        let parameters = "{\n\t\"documentTemplate\": \"\(tokenFaceImage)\",\n    \"image1\": \"\(bestImage)\",\n    \"extraData\": \"\(extradata)\"\n}"
        let postData = parameters.data(using: .utf8)
        
        var request = URLRequest(url: URL(string: baseUrl + methodAuth)!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print("REQUEST AUTHENTICATION")
            print(String(data: data, encoding: .utf8)!)
            
            result = String(data: data, encoding: .utf8)!
        }
        task.resume()
        
        return result
    }
    
    
    public func newOperation(operationType: OperationType, customerId: String, output: @escaping (SdkResult<String>) -> Void) {
        log("newOperation - start, device, coordinates, customerId - \(customerId)")
        SDKController.shared.newOperation(operationType: operationType, customerId: customerId, steps: nil, output: output, enableTracking: true)
    }
    
    public func closeSession() {
        log("closeSession")
        SDKController.shared.closeSession()
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
    
    public func launchGenerateRawTemplate() {
        log("LAUNCH GENERATE RAW TEMPLATE")
        
        let controller = RawTemplateController(
            base64: SdkConfigurationManager.base64,
            output: { sdkResult in
                self.showSdkResult(msg: "GENERATE RAW TEMPLATE - RESULT", sdkResultDict:
                                ["FinishStatus": sdkResult.finishStatus,
                                 "ErrorType": sdkResult.errorType,
                                 "Data": sdkResult.data?.count])
            })
        SDKController.shared.launchMethod(controller: controller)
    }
    
    func setCustomerId(customerId: String) {
        SDKController.shared.setCustomerId(customerId: customerId)
    }
}
