//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import phingersComponent
import sdk
import trackingComponent
import UIKit

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
                trackingController: trackingController
            )
        } else {
            // MANUAL License
            SDKController.shared.initSdk(
                license: SdkConfigurationManager.license,
                output: { sdkResult in
                    if sdkResult.finishStatus == .STATUS_OK {
                        self.log("Licencia manual seteada correctamente")
                    } else {
                        self.log("La licencia manual no es correcta")
                    }
                },
                trackingController: trackingController
            )
        }
    }

    public func launchPhingers(setTracking: Bool, viewController: UIViewController, phingersConfigurationData: PhingersConfigurationData, output: @escaping (SdkResult<PhingersResult>) -> Void){
        log("LAUNCH PHINGERS")
        
        let controller = PhingersController(data: phingersConfigurationData, output: output, viewController: viewController)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func matchPhinger(setTracking: Bool, phingersMatcherConfigurationData: PhingersMatcherConfigurationData, output: @escaping (SdkResult<FingersMatchResult>) -> Void)
    {
        log("LAUNCH MATCH")
        let controller = PhingersMatcherController(data: phingersMatcherConfigurationData, output: output)
        if setTracking{
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }

    
    public func newOperation(operationType: OperationType, customerId: String, output: @escaping (SdkResult<String>) -> Void) {
        log("newOperation - start, device, coordinates, customerId - \(customerId)")

        SDKController.shared.newOperation(operationType: operationType, customerId: customerId, output: output)
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
    
    func setCustomerId(customerId: String) {
        SDKController.shared.setCustomerId(customerId: customerId)
    }
}
