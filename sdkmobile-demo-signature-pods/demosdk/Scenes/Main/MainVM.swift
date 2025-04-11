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
import selphiComponent

protocol MainVMInput {
    func newOperation()
    func signatureSelphi()
    func signatureVideoId()
    func getLicense()
}

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {

    // TODO: Check what is this?
    private var tokenFaceImage = " "
    private var imageToken = " "
    private var OCRToken = " "
    private var bestImage = " "
    private var bestImageData: Data = Data()
    private var encodedReference: Data = Data()
    private var encodedProbe: Data = Data()
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
    
    
    func signatureSelphi() {
        SDKManager.shared.launchSignatureSelphi(setTracking: true, viewController: viewController, selphiConfigurationData: SdkConfigurationManager.selphiConfiguration, output: { selphiResult in
            self.parseSelphiResult(selphiResult: selphiResult)
        })
    }
    
    func parseSelphiResult(selphiResult: SdkResult<SelphiResult>){
        guard selphiResult.errorType == .NO_ERROR else {
            self.log(msg: "\(selphiResult.errorType)")
            return
        }
        guard let imageData = selphiResult.data?.bestImageData
                else
        {
            self.log(msg: "bestImage is nil")
            return
        }
        
        self.bestImage = imageData.base64EncodedString()
        self.bestImageData = imageData
        print(self.bestImage)
        
        let template = selphiResult.data?.template
        let templateRaw = selphiResult.data?.templateRaw
        let qrData = selphiResult.data?.qrData
        let bestImageData = selphiResult.data?.bestImageData
        
        let bestImageCroppedData = selphiResult.data?.bestImageCroppedData
        
        self.log(msg: "Image correctly fetched")
    }
    
    func signatureVideoId() {
        SDKManager.shared.launchSignatureVideoId(data: SdkConfigurationManager.videoIDConfiguration, setTracking: true, viewController: viewController, output: { videoIdResult in
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
