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

protocol MainVMInput {
    func newOperation()
    func selphi()
    func selphID()
    func generateRawTemplate()
    func tokenizeExtradata()
    func getLicense()
    func closeSession()
    func checkLiveness()
    func checkAuth()
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

    func selphi() {
        SDKManager.shared.launchSelphi(setTracking: true, viewController: viewController, selphiConfigurationData: SdkConfigurationManager.selphiConfiguration, output: { selphiResult in
            guard selphiResult.errorType == .NO_ERROR else {
                self.log(msg: selphiResult.errorType.toString())
                return
            }
            guard let imageData = selphiResult.data?.bestImageData
                    else
            {
                self.log(msg: "Selphi bestImage is nil")
                return
            }
            
            self.bestImage = imageData.base64EncodedString()
            self.log(msg: "Selphi Image correctly fetched")
        })
    }

    func selphID() {
        SDKManager.shared.launchSelphId(setTracking: true, viewController: viewController, selphIDConfigurationData: SdkConfigurationManager.selphIDConfiguration, output:  { selphIDResult in
            guard selphIDResult.errorType == .NO_ERROR else {
                self.log(msg: selphIDResult.errorType.toString())
                return
            }
            
            guard let result = selphIDResult.data?.ocrResults
                    else
            {
                return
            }
            
            if let dictionary = selphIDResult.data?.ocrResults {
                self.ocr = Dictionary(uniqueKeysWithValues: dictionary.flatMap { (key, value) -> (String, String)? in
                    return (key, value)
                })
            } else {
                print("el OCR es nulo.")
            }
            self.bestImageData = selphIDResult.data?.faceImageData ?? Data()
            self.log(msg: String(result.count))
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
    
    // Never used
    func setCustomerId() {
        SDKManager.shared.setCustomerId(customerId: "nuevoCustomerId")
    }
    
    func checkLiveness() {
        self.log(msg: SDKManager.shared.launchCheckLiveness(bestImage: bestImage,
                                                            extradata: SDKManager.shared.launchExtradata().data ?? "",
                                              baseUrl: baseUrl,
                                              methodPassiveLivenesTracking: methodPassiveLivenesTracking))
    }
    
    func checkAuth() {
        self.log(msg: SDKManager.shared.launchCheckAuth(tokenFaceImage: tokenFaceImage, bestImage: bestImage, extradata: extradataToken, baseUrl: baseUrl, methodAuth: methodAuthenticateFacial))
    }
    

    func generateRawTemplate() {
        SDKManager.shared.launchGenerateRawTemplate()
    }

    // Never used
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
