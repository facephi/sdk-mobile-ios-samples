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
    func updateImages(images: [UIImage?])
}

class MainVM {

    private var tokenFaceImage = " "
    private var extradataToken = " "
    private var selfie = " "
    private var documentFaceData: Data = Data()
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
            
            self.selfie = imageData.base64EncodedString()
            self.log(msg: "Selphi Image correctly fetched")
            self.delegate?.updateImages(images: [UIImage(data: imageData)])

        })
    }

    func selphID() {
        SDKManager.shared.launchSelphId(setTracking: true, viewController: viewController, selphIDConfigurationData: SdkConfigurationManager.selphIDConfiguration, output:  { selphIDResult in
            guard selphIDResult.errorType == .NO_ERROR else {
                self.log(msg: selphIDResult.errorType.toString())
                return
            }
            if let dictionary = selphIDResult.data?.ocrResults {
                let ocr = Dictionary(uniqueKeysWithValues: dictionary.flatMap { (key, value) -> (String, String)? in
                    return (key, value)
                })
                self.log(msg: "OCR Data:\n\(ocr)")
            } else {
                self.log(msg: "OCR Data not found")
            }
            self.documentFaceData = selphIDResult.data?.faceImageData ?? Data()
            let frontDocument = selphIDResult.data?.frontDocumentData ?? Data()
            let backDocument = selphIDResult.data?.backDocumentData ?? Data()
            self.delegate?.updateImages(images: [
                UIImage(data: self.documentFaceData),
                UIImage(data: frontDocument),
                UIImage(data: backDocument)]
            )
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
        SDKManager.shared.setCustomerId(customerId: "newCustomerId")
    }
    
    func checkLiveness() {
        self.log(msg: SDKManager.shared.launchCheckLiveness(bestImage: selfie,
                                                            extradata: SDKManager.shared.launchExtradata().data ?? "",
                                                            baseUrl: SdkConfigurationManager.BASE_URL,
                                                            methodPassiveLivenesTracking: SdkConfigurationManager.METHOD_PASSIVE_LIVENES))
    }
    
    func checkAuth() {
        self.log(msg: SDKManager.shared.launchCheckAuth(tokenFaceImage: tokenFaceImage,
                                                        bestImage: selfie,
                                                        extradata: extradataToken,
                                                        baseUrl: SdkConfigurationManager.BASE_URL,
                                                        methodAuth: SdkConfigurationManager.METHOD_AUTH_FACIAL))
    }
    
    func generateRawTemplate() {
        SDKManager.shared.launchGenerateRawTemplate()
    }

    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
