//
//  MainVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 6/5/22.
//

import core
import Foundation
import UIKit
import AVFoundation
//import phingersComponent

protocol MainVMInput {
    func newOperation()
    func tokenizeExtradata()
    func videoId()
    func getLicense()
    func closeSession()
}

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {
    // MARK: - VARS
    private let baseUrl = "https://external-selphid-sdk.facephi.dev/"
    private let methodPassiveLivenesTracking = "api/v1/selphid/passive-liveness/evaluate"
    private let methodAuthenticateFacial = "api/v1/selphid/authenticate-facial/document/face-image"
   
    //VOICE Constants
    private let baseVoiceUrl = "https://external-voice-sdk.facephi.dev/"
    private let methodVoiceEnrollment = "api/v1/enrollment"
    private let methodVoiceMatching = "api/v1/authentication"
    private let liveness_threshold: Double = 0.5

    // TODO: Check what is this?
    private var tokenFaceImage = " "
    private var extradataToken = " "
    private var imageToken = " "
    private var OCRToken = " "
    private var bestImage = " "
    private var bestImageData: Data = Data()
    private var encodedReference: Data = Data()
    private var encodedProbe: UIImage = UIImage()
    private var ocr: [String: String] = [:]
    private var audios: [Data]?
    private var audioTemplate: String?
    private var generatedQrImage: UIImage = UIImage()
    // TODO: Check what is this?

    
    private var delegate: MainVMOutput?
    
    private let viewController: UIViewController

    init(viewController: UIViewController, delegate: MainVMOutput) {
        self.delegate = delegate
        self.viewController = viewController
        SDKManager.shared.mainVC = delegate
        getLicense()
    }

    // MARK: - FUNC
    func log(msg: String) {
        delegate?.show(msg: msg)
    }
}

// MARK: - MainVMInput
extension MainVM: MainVMInput {
    
    func getLicense() {
        // Initializes for the first time, so it launches the GetLicense functionality
        let _ = SDKManager.shared
    }
    
    func newOperation() {
        SDKManager.shared.newOperation(operationType: .ONBOARDING, customerId: SdkConfigurationManager.CUSTOMER_ID, output: { sdkResult in
            self.log(msg: sdkResult.data != nil ? "New Operation with ID: \(sdkResult.data)": "ERROR: NewOperation's data output is nil")
        })
    }

    func tokenizeExtradata() {
        guard let tokenizeExtradata = SDKManager.shared.launchExtradata().data
        else {
            return
        }
        self.extradataToken = tokenizeExtradata
        self.log(msg: self.extradataToken)
    }
    
    func videoId() {
        SDKManager.shared.launchVideoId(data: SdkConfigurationManager.videoIDConfiguration, setTracking: true, viewController: viewController, output: { videoIdResult in
            if videoIdResult.finishStatus == .STATUS_OK {
                self.log(msg: "Status OK \(videoIdResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(videoIdResult.errorType)")
            }
        })
    }
    
    // Never used
    func setCustomerId() {
        SDKManager.shared.setCustomerId(customerId: "nuevoCustomerId")
    }
    
    // Never used
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
