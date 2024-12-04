//
//  SDKManager.swift
//  demosdk
//
//  Created by Faustino Flores García on 5/5/22.
//

import core
import Foundation
import sdk
import trackingComponent
import UIKit
import voiceIDComponent
import tokenizeComponent

import ReplayKit //TODO: Check because we should move this

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

        // MANUAL License
//        SDKController.shared.initSdk(
//            license: SdkConfigurationManager.license,
//            output: { sdkResult in
//                if sdkResult.finishStatus == .STATUS_OK {
//                    self.log("Licencia manual seteada correctamente")
//                } else {
//                    self.log("La licencia manual no es correcta")
//                }
//            },
//            trackingController: trackingController,
//            tokenizeController: tokenizeController,
//            behaviorController: behaviorController
//        )
        
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
            tokenizeController: tokenizeController
        )
    }
        
    public func launchVoiceId(data: EnvironmentAudioRecordingData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<AudioRecordingResponseResult>) -> Void)
    {
        log("LAUNCH VOICE ID")
        
        let controller = VoiceIDController(
            data: data,
            viewController: viewController,
            output: { sdkResult in
                let voiceIdSdkResult = SdkResult<AudioRecordingResponseResult>(finishStatus: sdkResult.finishStatus, errorType: sdkResult.errorType, data: sdkResult.data)
                output(voiceIdSdkResult)
            })
        SDKController.shared.launch(controller: controller)
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
