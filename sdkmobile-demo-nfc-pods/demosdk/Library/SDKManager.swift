//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import sdk
import nfcComponent
import trackingComponent
import UIKit

protocol SDKManagerDelegate: AnyObject {
    func log(msg: String)
}

class SDKManager {
    // MARK: - VARS
    public static var shared: SDKManager = SDKManager()
    
    private let TAG = "APP_MANAGER"
    
    // MARK: - INIT
    init() {
        let trackingController = TrackingController(trackingError: { trackingError in
            self.log("TRACKING ERROR: \(trackingError)")
        })
        trackingController.tenantIdDemo = SdkConfigurationManager.CUSTOM_TENANT_ID
        
        // MANUAL License
//        SDKController.shared.initSdk(license: SdkConfigurationManager.LICENSE, output: { sdkResult in
//            if sdkResult.finishStatus == .STATUS_OK {
//                self.log("Licencia manual seteada correctamente")
//            } else {
//                self.log("La licencia manual no es correcta")
//            }
//        }, trackingController: trackingController)
        
        // AUTO License
        SDKController.shared.initSdk(licensingUrl: SdkConfigurationManager.LICENSING_URL, apiKey: SdkConfigurationManager.APIKEY_LICENSING, output: { sdkResult in
            if sdkResult.finishStatus == .STATUS_OK {
                self.log("Licencia automática seteada correctamente")
            } else {
                self.log("Ha ocurrido un error al intentar obtener la licencia: \(sdkResult.errorType)")
            }
        }, trackingController: trackingController)
    }
    
    // MARK: - LAUNCH FUNCS
    public func launchNfc(setTracking: Bool, nfcConfigurationData: NfcConfigurationData, output: @escaping (SdkResult<NfcResult>) -> Void) {
        log("LAUNCH NFC")
        
        let controller = NfcController(data: nfcConfigurationData, output: output, stateDelegate: nil)
        if setTracking {
            SDKController.shared.launch(controller: controller)
        } else {
            SDKController.shared.launchMethod(controller: controller)
        }
    }
    
    public func newOperation(operationType: sdk.OperationType, customerId: String, output: @escaping (SdkResult<String>) -> ()) {
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
    
    func launchExtraData() -> SdkResult<String> {
        SDKController.shared.getExtraData()
    }
}
