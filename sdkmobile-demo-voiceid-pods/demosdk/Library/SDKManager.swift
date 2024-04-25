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
import statusComponent

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
    
    let statusController = StatusController()

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
//            statusController: statusController
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
            tokenizeController: tokenizeController,
            statusController: statusController
        )
    }
        
    public func launchVoiceId(data: VoiceConfigurationData, setTracking: Bool, viewController: UIViewController, output: @escaping (SdkResult<VoiceResult>) -> Void)
    {
        log("LAUNCH VOICE ID")
        
        let controller = VoiceController(
            data: data,
            output: { sdkResult in
                let voiceIdSdkResult = SdkResult(finishStatus: sdkResult.finishStatus, errorType: sdkResult.errorType, data: sdkResult.data)
                output(voiceIdSdkResult)
            }, viewController: viewController)
        if setTracking{
            SDKController.shared.launch(controller: controller)
        }else{
            SDKController.shared.launchMethod(controller: controller)
        }
        
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
