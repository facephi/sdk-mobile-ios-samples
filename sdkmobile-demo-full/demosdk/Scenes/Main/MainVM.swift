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
import phingersTFComponent
import selphiComponent
import selphidComponent
import captureComponent
import videocallComponent
import videoidComponent
import videoRecordingComponent
import voiceIDComponent
import nfcComponent
import termsConditionsComponent

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {
    //VOICE Constants
    private let baseVoiceUrl = "VOICE_SDK_BASE_URL"
    private let methodVoiceEnrollment = "api/v1/enrollment"
    private let methodVoiceMatching = "api/v1/authentication"
    private let liveness_threshold: Double = 0.5
    
    // TODO: Check what is this?
    private var imageToken = " "
    private var bestImageBase64: String = " "
    private var encodedReference: String = " "
    private var encodedProbe: Data = Data()
    private var audios: [Data]?
    private var audioTemplate: String?
    private var generatedQrImage: UIImage = UIImage()
    private var base64FaceImage: String = " "
    private var documentFaceImageMapTokenized: String?
    // TODO: Check what is this?
    
    private var delegate: MainVMOutput?
    private let viewController: UIViewController
    
    
    //IDAPI
    private var validationDataResponse: DocumentValidationDataResponse?
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
    
    init(viewController: UIViewController, delegate: MainVMOutput) {
        self.delegate = delegate
        self.viewController = viewController
        SDKManager.mainVC = delegate
        getLicense()
    }
    
    // MARK: - FUNC
    func log(msg: String) {
        delegate?.show(msg: msg)
    }
}

// MARK: - Inputs
extension MainVM {
    private var
    validationsBaseUrl: String {
        let configuredValue = PrefManager.get(String.self, forKey: .KEY_VALIDATION_URL)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let configuredValue, !configuredValue.isEmpty else {
            return SdkConfigurationManager.validationsUrl
        }
        return configuredValue
    }
    
    private var validationsApiKey: String {
        let configuredValue = PrefManager.get(String.self, forKey: .KEY_VALIDATION_API_KEY)?.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let configuredValue, !configuredValue.isEmpty else {
            return SdkConfigurationManager.validationsApiKey
        }
        return configuredValue
    }
    
    func generateQr() {
        SDKManager.shared.launchQrGenerator(setTracking: true,
                                            viewController: viewController,
                                            qrGeneratorConfigurationData: SdkConfigurationManager.qrGeneratorConfiguration,
                                            output: { qrGeneratorResult in
            guard qrGeneratorResult.errorType == .NO_ERROR else {
                self.log(msg: "\(qrGeneratorResult.errorType)")
                return
            }
            
            guard let result = qrGeneratorResult.data
            else
            {
                self.log(msg: "QRGenerator KO")
                return
            }
            self.log(msg: "QRGenerator OK: " + result.description)
            self.generatedQrImage = result
        })
    }
    
    func getLicense() {
        // Initializes for the first time, so it launches the GetLicense functionality
        let _ = SDKManager.shared
    }
    
    func newOperation() {
        self.documentValidationService = nil
        SDKManager.shared.newOperation(operationType: .ONBOARDING, customerId: SdkConfigurationManager.customerId, output: { sdkResult in
            self.operationId = sdkResult.data
            self.log(msg: sdkResult.data != nil ? "New Operation with ID: \(sdkResult.data)": "ERROR: \(sdkResult.errorType)")
        })
    }
    
    func initFlow() {
        SDKManager.shared.launchFlow(customerId: SdkConfigurationManager.customerId, viewController: viewController, output: {
            self.log(msg: $0.data ?? "No data")
        })
    }
    
    func initFlowOffline() {
        SDKManager.shared.launchFlow(customerId: SdkConfigurationManager.customerId, viewController: viewController, output: {
            self.log(msg: $0.data ?? "No data")
        }, offline: true)
    }
    
    func flowNextStep() {
        SDKManager.shared.flowNextStep()
    }
    
    func cancelLaunch() {
        SDKManager.shared.cancelLaunch()
    }

    func enableVolumeUpCancelLaunch() {
        SDKManager.shared.enableVolumeUpCancelLaunch()
    }

    func disableVolumeUpCancelLaunch() {
        SDKManager.shared.disableVolumeUpCancelLaunch()
    }
    
    func selphi(configuration: SelphiConfigurationData) {
        SDKManager.shared.launchSelphi(setTracking: true, viewController: viewController, selphiConfigurationData: configuration, output: { selphiResult in
            self.parseSelphiResult(selphiResult: selphiResult)
        })
    }
    
    func signatureSelphi(configuration: SelphiConfigurationData) {
        SDKManager.shared.launchSignatureSelphi(setTracking: true, viewController: viewController, selphiConfigurationData: configuration, output: { selphiResult in
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
            self.saveNfcParameters(data: result)

            self.log(msg: "Found \(result.ocrResults?.count ?? 0) OCR fields")
            if let vendor = result.extractorVendor {
                self.log(msg: "Extractor vendor: \(vendor.rawValue)")
            }
            if !result.parallelResults.isEmpty {
                let keys = result.parallelResults.keys.sorted().joined(separator: ", ")
                self.log(msg: "Parallel extractor results: \(keys)")
            }
            for (index, encoded) in result.encodedDataImages.enumerated() {
                let token = result.tokenEncodedDataImages.indices.contains(index)
                    ? result.tokenEncodedDataImages[index].token
                    : ""
                self.log(
                    msg: "Encoded data crop[\(index)] format=\(encoded.format) side=\(encoded.side.rawValue) token=\(token)"
                )
            }
        })
    }
    
    func nfc(configuration: NfcConfigurationData) {
        SdkConfigurationManager.persistNfcConfigurationData(configuration)
        SDKManager.shared.launchNfc(setTracking: true, viewController: viewController, nfcConfigurationData: configuration, output: { nfcResult in
            guard nfcResult.errorType == .NO_ERROR else {
                self.log(msg: "\(nfcResult.errorType)")
                return
            }
            
            guard let _ = nfcResult.data
            else
            {
                self.log(msg: "NFC KO")
                return
            }
            self.log(msg: "NFC OK")
        })
    }
    
    func launchQr(configuration: QrCaptureConfigurationData) {
        SDKManager.shared.launchQrReader(setTracking: true, viewController: viewController, qrReaderConfigurationData: configuration, output: { qrReaderResult in
            guard qrReaderResult.errorType == .NO_ERROR else {
                self.log(msg: "\(qrReaderResult.errorType)")
                return
            }
            
            guard let result = qrReaderResult.data
            else
            {
                self.log(msg: "QRReader KO")
                return
            }
            self.log(msg: "QRReader OK: " + result.qrText)
        })
    }
    
    func launchCaptureCUE(configuration: FileUploaderConfigurationData) {
        // swiftlint:disable all
        SDKManager.shared.launchCaptureCUE(setTracking: true, viewController: viewController, fileUploaderConfigurationData: configuration, output: { captureResult in
            guard captureResult.errorType == .NO_ERROR else {
                self.log(msg: "\(captureResult.errorType)")
                return
            }
            
            guard let result = captureResult.data else {
                self.log(msg: "Capture KO")
                return
            }
            switch result.documentImages.first?.content {
            case .uploaderDocument(let doc):
                print(doc.bytes)
                break
            case .uploaderImage(let image):
                print(image.image)
                break
            case .none:
                break
            }
            self.log(msg: "Capture OK: " + String(result.documentImages.count))
        })
    }
    
    func tokenizeExtradata() {
        let result = SDKManager.shared.launchExtradata()
        guard let tokenizeExtradata = result.data else {
            self.log(msg: "Can't tokenize the extra data: \(result.errorType)")
            return
        }
        self.log(msg: tokenizeExtradata)
    }
    
    func phingers(configuration: PhingersConfigurationData) {
        SDKManager.shared.launchPhingers(setTracking: true, viewController: viewController, phingersConfigurationData: configuration, output: { phingersResult in
            if phingersResult.errorType == .NO_ERROR {
                self.log(msg: "Status OK \(phingersResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(phingersResult.errorType)")
            }
        })
    }
    
    func videoCall(configuration: VideoCallConfigurationData) {
        SDKManager.shared.launchVideoCall(data: configuration, setTracking: true, viewController: viewController, output: { videocallResult in
            guard videocallResult.errorType == .NO_ERROR else {
                self.log(msg: "VideoCall ERROR: \(videocallResult.errorType)")
                return
            }
            self.log(msg: "VideoCall OK — \(Self.describeVideoCallStatus(videocallResult.data))")
        })
    }

    func resumeVideoCall() {
        SDKManager.shared.resumeVideoCall()
        log(msg: "resume() invoked (use after MINIMIZED)")
    }

    func returnToVideoCall() {
        SDKManager.shared.returnToVideoCall()
        log(msg: "returnToCall() invoked (use during screen sharing)")
    }

    func stopVideoCallScreenSharing() {
        SDKManager.shared.stopVideoCallScreenSharing { [weak self] state in
            self?.log(msg: "stopScreenSharing: \(Self.describeScreenSharingState(state))")
        }
    }

    private static func describeVideoCallStatus(_ status: VideoCallStatus?) -> String {
        switch status {
        case .RECORDING_SCREEN:
            return "RECORDING_SCREEN — try Return to call or Stop sharing"
        case .MINIMIZED:
            return "MINIMIZED — try Resume call"
        case .VIDEOCALL_FINISHED:
            return "VIDEOCALL_FINISHED"
        case nil:
            return "finish OK (no VideoCallStatus payload)"
        }
    }

    private static func describeScreenSharingState(_ state: VideoCallScreenSharingState) -> String {
        switch state {
        case .sharing: return "sharing (still active)"
        case .finish: return "finish (stopped OK)"
        case .cancelByUser: return "cancelByUser (stopped OK)"
        case .permissionError: return "permissionError"
        case .networkConnectionError: return "networkConnectionError"
        case .agentHangup: return "agentHangup"
        case .unknownError: return "unknownError"
        }
    }
    
    func hangout() {
        SDKManager.shared.hangoutVideoCall()
        log(msg: "hangout() invoked")
    }
    
    func videoId(configuration: VideoIDConfigurationData) {
        SDKManager.shared.launchVideoId(data: configuration, setTracking: true, viewController: viewController, output: { videoIdResult in
            if videoIdResult.errorType == .NO_ERROR {
                self.bestImageToken = videoIdResult.data?.faceImageTokenized ?? ""
                self.tokenFaceImage = videoIdResult.data?.documentFaceImageTokenized ?? ""
                self.documentFaceImageMapTokenized = videoIdResult.data?.documentFaceImageMapTokenized ?? ""
                self.log(msg: "Status OK \(videoIdResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(videoIdResult.errorType)")
            }
        })
    }
    
    func signatureVideoId(configuration: VideoIDConfigurationData) {
        SDKManager.shared.launchSignatureVideoId(data: configuration, setTracking: true, viewController: viewController, output: { videoIdResult in
            if videoIdResult.errorType == .NO_ERROR {
                self.bestImageToken = videoIdResult.data?.faceImageTokenized ?? ""
                self.tokenFaceImage = videoIdResult.data?.documentFaceImageTokenized ?? ""
                self.documentFaceImageMapTokenized = videoIdResult.data?.documentFaceImageMapTokenized ?? ""
                self.log(msg: "Status OK \(videoIdResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(videoIdResult.errorType)")
            }
        })
    }
    
    func voiceId(configuration: VoiceConfigurationData) {
        SDKManager.shared.launchVoiceId(data: configuration ,setTracking: true, viewController: viewController, output: { voiceIdResult in
            if voiceIdResult.errorType == .NO_ERROR,
               let audios = voiceIdResult.data?.audios {
                self.audios = audios
                self.resetAudiosDirectory()
                self.saveAudios()
                self.log(msg: "Status OK \(voiceIdResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(voiceIdResult.errorType)")
            }
        })
    }
    
    private func resetAudiosDirectory() {
        
        //Delete existing audios
        do {
            try FileManager.default.removeItem(at: SdkConfigurationManager.audiosDirectory)
        } catch {
            print("COULD NOT DELETE OLD AUDIO FILES")
        }
        //Create directory if not created
        do {
            try FileManager.default.createDirectory(at: SdkConfigurationManager.audiosDirectory,
                                                    withIntermediateDirectories: true)
        } catch {
            if !FileManager.default.fileExists(atPath: SdkConfigurationManager.audiosDirectory.path) {
                print("AUDIOS FOLDER COULD NOT BE CREATED")
            }
        }
    }
    
    private func saveAudios() {
        guard let audios else { return }
        for (i, audio) in audios.enumerated() {
            let audioFileName = SdkConfigurationManager.audiosDirectory.appendingPathComponent("audio" + String(i) + ".wav")
            do {
                try audio.write(to: audioFileName)
            } catch {
                print("AUDIO SAVING ERROR: Audio " + audioFileName.absoluteString + " could not be saved")
            }
        }
    }
    // Never used
    func setCustomerId() {
        SDKManager.shared.setCustomerId(customerId: "nuevoCustomerId")
    }
    
    func voiceEnrollment() {
        var config = SdkConfigurationManager.voiceIDConfiguration
        if config.phrases.count < 3 {
            config.phrases.append("Prueba de voz")
        }
        if config.phrases.count < 3 {
            config.phrases.append("El cielo es azul")
        }
        
        SDKManager.shared.launchVoiceId(data: config, setTracking: true, viewController: viewController, output: { voiceIdResult in
            if voiceIdResult.errorType == .NO_ERROR,
               let audios = voiceIdResult.data?.audios,
               let tokenizedAudios = voiceIdResult.data?.tokenizedAudios {
                self.audios = audios
                self.resetAudiosDirectory()
                self.saveAudios()
                self.log(msg: "Status OK \(voiceIdResult.finishStatus)")
                self.manageEnrollment(tokenizedAudios: tokenizedAudios)
            } else {
                self.log(msg: "Status KO \(voiceIdResult.errorType)")
            }
        })
    }
    
    private func manageEnrollment(tokenizedAudios: [String]) {
        SDKManager.shared.launchVoiceEnrollment(audios: tokenizedAudios, baseVoiceUrl: self.baseVoiceUrl, methodAuth: self.methodVoiceEnrollment, output: { sdkResult in
            guard let enrollmentResult = sdkResult.data else {
                self.log(msg: "launchVoiceEnrollment - Network request to enroll failed with \(sdkResult.errorType)")
                return
            }
            self.audioTemplate = enrollmentResult.template
            var validatedAudios = "Enrolled Audios:\n"
            enrollmentResult.validate_audios_result.forEach({
                validatedAudios.append("\($0.audio_position) - Result=\($0.result_code)")
            })
            self.log(msg: validatedAudios)
        })
    }
    
    func voiceMatching() {
        SDKManager.shared.launchVoiceId(data: SdkConfigurationManager.voiceIDConfiguration, setTracking: true, viewController: viewController, output: { voiceIdResult in
            if voiceIdResult.errorType == .NO_ERROR,
               let audios = voiceIdResult.data?.audios,
               let tokenizedAudio = voiceIdResult.data?.tokenizedAudios.first,
               let audioTemplate = self.audioTemplate {
                self.audios = audios
                self.resetAudiosDirectory()
                self.saveAudios()
                SDKManager.shared.launchVoiceMatching(
                    audio: tokenizedAudio,
                    template: audioTemplate,
                    liveness_threshold: self.liveness_threshold,
                    baseVoiceUrl: self.baseVoiceUrl,
                    methodAuth: self.methodVoiceMatching,
                    output: { self.log(msg: $0) })
            } else {
                self.log(msg: "Status KO \(voiceIdResult.errorType)")
            }
        })
    }
    
    func generateRawTemplate() {
        guard let bestImageData else {
            self.log(msg: "Can't generateRawTemplate because bestImageData is nil")
            return
        }
        SDKManager.shared.launchGenerateRawTemplate(data: bestImageData)
    }
    
    func startVideoRecording(configuration: VideoRecordingConfigurationData) {
        SDKManager.shared.launchVideoRecording(viewController: viewController, configuration: configuration)
    }
    
    func stopVideoRecording() {
        SDKManager.shared.stopVideoRecording()
    }
    
    // Never used
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
            baseUrl: validationsBaseUrl,
            apiKey: validationsApiKey,
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
            baseUrl: validationsBaseUrl,
            apiKey: validationsApiKey,
            extraDataResult: SDKManager.shared.getExtraDataResult(),
            tokenOcr: tokenOcr, //?
            operationId: operationId)

        service.execute(callback: { self.log(msg: $0) })
    }

    func launchTermsConditions(configuration: TermsConditionsConfigurationData) {
        SDKManager.shared.launchTermsConditions(setTracking: true, viewController: viewController, termsConditionsConfigurationData: configuration, output: { termsConditionsResult in
            guard termsConditionsResult.errorType == .NO_ERROR else {
                self.log(msg: "\(termsConditionsResult.errorType)")
                return
            }

            guard termsConditionsResult.data != nil else {
                self.log(msg: "TermsConditions KO")
                return
            }

            self.log(msg: "TermsConditions OK")
        })
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
            baseUrl: validationsBaseUrl,
            apiKey: validationsApiKey,
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
            baseUrl: validationsBaseUrl,
            apiKey: validationsApiKey,
            extraDataResult: SDKManager.shared.getExtraDataResult(),
            finishTrackingData: configuration
        )
        
        service.execute(callback: { self.log(msg: $0) })
    }
    
    
    private func saveNfcParameters(data: SelphIDResult?) {
        guard let data else { return }
        
        PrefManager.set(data.getNfcKey(), forKey: .KEY_NFC_SUPPORT_NUMBER)
        PrefManager.set(data.getBirthDate(), forKey: .KEY_NFC_BIRTH_DATE)
        PrefManager.set(data.getExpiryDate(), forKey: .KEY_NFC_EXPIRATION_DATE)
    }
}
