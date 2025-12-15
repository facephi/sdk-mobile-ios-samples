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
import selphidComponent
import captureComponent

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {
    // MARK: - VARS
    private var delegate: MainVMOutput?
    private let viewController: UIViewController
    
    //IDAPI
    private var documentValidationService: DocumentValidationServiceProtocol?
    private var operationId: String?
    private var tokenFaceImage: String?
    private var bestImageData: Data?
    private var bestImageToken: String?
    private var tokenOcr: String?
    private var frontDocumentImage: String?
    private var backDocumentImage: String?
    private var requestedScanReference: String?
    private var status: String?
    private var documentType: String?
    private var countryIssuer: String?
    private var ocr: [String: String]?
    
    private var validationDataResponse: DocumentValidationDataResponse?

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

// MARK: - Inputs
extension MainVM {
    func getLicense() {
        // Initializes for the first time, so it launches the GetLicense functionality
        let _ = SDKManager.shared
    }
    
    func newOperation() {
        self.documentValidationService = nil
        SDKManager.shared.newOperation(operationType: .ONBOARDING, customerId: SdkConfigurationManager.customerId, output: { sdkResult in
            guard let operationId = sdkResult.data else {
                self.log(msg: "NewOperation ERROR: \(sdkResult.errorType)")
                return
            }
            self.log(msg: "\(SdkConfigurationManager.trackingVersionTag) - New Operation \(operationId)")
            self.operationId = operationId
        })
    }
    
    func initFlow() {
        SDKManager.shared.launchFlow(customerId: SdkConfigurationManager.customerId, viewController: viewController, output: {
            self.log(msg: $0.data ?? "No data")
        })
    }
    
    func flowNextStep() {
        SDKManager.shared.flowNextStep()
    }
    
    func flowCancel() {
        SDKManager.shared.cancelFlow()
    }
    
    func selphi(configuration: SelphiConfigurationData) {
        SDKManager.shared.launchSelphi(setTracking: true, viewController: viewController, selphiConfigurationData: configuration, output: { selphiResult in
            self.parseSelphiResult(selphiResult: selphiResult)
        })
    }
    
    func parseSelphiResult(selphiResult: SdkResult<SelphiResult>){
        guard selphiResult.errorType == .NO_ERROR else {
            self.log(msg: "\(selphiResult.errorType)")
            return
        }
        guard let result = selphiResult.data else {
            self.log(msg: "SelphiResult is nil")
            return
        }
        self.bestImageData = result.bestImageData
        self.bestImageToken = result.bestImageTokenized
        
        self.log(msg: "Image correctly fetched")
    }
    
    func selphID(configuration: SelphIDConfigurationData) {
        SDKManager.shared.launchSelphId(setTracking: true, viewController: viewController, selphIDConfigurationData: configuration, output:  { selphIDResult in
            guard selphIDResult.errorType == .NO_ERROR else {
                self.log(msg: "\(selphIDResult.errorType)")
                return
            }
            
            guard let result = selphIDResult.data else {
                self.log(msg: "SelphIDResult is nil")
                return
            }
            
            self.ocr = result.ocrResults
            self.tokenOcr = result.tokenOCR
            self.tokenFaceImage = result.tokenFaceImage
            self.countryIssuer = result.countryCaptured
            self.documentType = result.documentTypeCaptured?.rawValue
            self.frontDocumentImage = result.frontDocumentImage
            self.backDocumentImage = result.backDocumentImage

            self.log(msg: String("Found \(result.ocrResults?.count ?? 0) ocr results"))
        })
    }
    
    func launchFileUploader(configuration: FileUploaderConfigurationData) {
            SDKManager.shared.launchFileUploader(setTracking: true, viewController: viewController, fileUploaderConfigurationData: configuration, output: { captureResult in
            guard captureResult.errorType == .NO_ERROR,
                let result = captureResult.data else {
                self.log(msg: "\(captureResult.errorType)")
                return
            }
            self.log(msg: "File Uploader captured: \(String(result.documentImages.count)) images")
        })
    }
    
    func tokenizeExtradata() {
        let result = SDKManager.shared.getExtraDataResult()
        guard let tokenizeExtradata = result.data else {
            self.log(msg: "Can't tokenize the extra data: \(result.errorType)")
            return
        }
        self.log(msg: tokenizeExtradata)
    }
    
    // Never used
    func setCustomerId() {
        guard let newCustomerId = PrefManager.get(String.self, forKey: .KEY_CUSTOMER_ID),
        newCustomerId.isEmpty == false else {
            self.log(msg: "Can't set new CustomerId because it's nil or empty. Make sure to save after modifying the settings")
            return
        }
        SDKManager.shared.setCustomerId(customerId: newCustomerId)
    }
    
    func generateRawTemplate() {
        guard let bestImageData else {
            self.log(msg: "Can't generateRawTemplate because bestImageData is nil")
            return
        }
        SDKManager.shared.launchGenerateRawTemplate(data: bestImageData)
    }
    
    func startVideoRecording() {
        SDKManager.shared.launchVideoRecording(viewController: viewController)
    }
    
    func stopVideoRecording() {
        self.log(msg: "Stopped VideoRecording")
        SDKManager.shared.stopVideoRecording()
    }
    
    func closeSession() {
        SDKManager.shared.closeSession()
    }
    
    func launchIdentityValidation() {
        guard let operationId else {
            self.log(msg: "No operation created")
            return
        }
        guard let tokenFaceImage else {
            self.log(msg: "SelphID document face image not found")
            return
        }
        guard let bestImageToken else {
            self.log(msg: "Selphi image not found")
            return
        }
        
        let service = IdentityValidationService(
            baseUrl: SdkConfigurationManager.validationsUrl,
            apiKey: SdkConfigurationManager.validationsApiKey,
            extraDataResult: SDKManager.shared.getExtraDataResult(),
            tokenFaceImage: tokenFaceImage,
            bestImageToken: bestImageToken,
            operationId: operationId)
        
        service.execute(callback: { self.log(msg: $0) })
    }
    
    func launchExtractDocument() {
        guard let operationId else {
            self.log(msg: "No operation created")
            return
        }
        guard let tokenOcr else {
            self.log(msg: "Ocr not found")
            return
        }
        
        let service = ExtractDocumentDataService(
            baseUrl: SdkConfigurationManager.validationsUrl,
            apiKey: SdkConfigurationManager.validationsApiKey,
            extraDataResult: SDKManager.shared.getExtraDataResult(),
            tokenOcr: tokenOcr, //?
            operationId: operationId)
        
        service.execute(callback: { self.log(msg: $0) })
    }
    
    func launchDocumentValidationStart() {
        guard let frontDocumentImage, let backDocumentImage, let countryIssuer, let documentType else {
            self.log(msg: "Validation can't be started because the document's capture is not completed")
            return
        }
        guard let operationId else {
            self.log(msg: "No operation created")
            return
        }
        
        self.documentValidationService = DocumentValidationService(
            baseUrl: SdkConfigurationManager.validationsUrl,
            apiKey: SdkConfigurationManager.validationsApiKey,
            extraDataResult: SDKManager.shared.getExtraDataResult(),
            frontDocumentImage: frontDocumentImage,
            backDocumentImage: backDocumentImage,
            country: countryIssuer,
            documentType: documentType,
            operationId: operationId)
        
        self.documentValidationService?.start(callback: { self.log(msg: $0) })
    }
    func launchDocumentValidationStatus() {
        self.documentValidationService?.status(callback: { self.log(msg: $0) })
    }
    func launchDocumentValidationData() {
        self.documentValidationService?.data(callback: { dataResult in
            self.validationDataResponse = dataResult.decodeJsonString()
            self.log(msg: dataResult)
        })
    }
    
    func launchFinishTracking(configuration: FinishTrackingData) {
        let service = FinishTrackingService(
            baseUrl: SdkConfigurationManager.validationsUrl,
            apiKey: SdkConfigurationManager.validationsApiKey,
            extraDataResult: SDKManager.shared.getExtraDataResult(),
            finishTrackingData: configuration
        )
        
        service.execute(callback: { self.log(msg: $0) })
    }
}
