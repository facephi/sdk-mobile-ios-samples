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
import voiceIDComponent

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {
    // MARK: - VARS
    private let baseUrlV5 = "https://external-selphid-sdk.facephi.dev/v5/"
    private let baseUrlV6 = "https://external-selphid-sdk.facephi.dev/v6/"
    private let methodPassiveLivenesTrackingToken = "api/v1/selphid/passive-liveness/evaluate/token"
    private let methodPassiveLivenesTrackingImage = "api/v1/selphid/passive-liveness/evaluate"
    private let methodAuthenticateFacialToken = "/api/v1/selphid/authenticate-facial/templates"
    private let methodAuthenticateFacialImage = "/api/v1/selphid/authenticate-facial/images"
    private let methodAuthenticateFacialImageToken = "/api/v1/selphid/authenticate-facial/image/template"
    private let methodAuthenticateDocumentFacialToken = "/api/v1/selphid/authenticate-facial/document/face-template"
    
    //VOICE Constants
    private let baseVoiceUrl = "https://external-voice-sdk.facephi.dev/"
    private let methodVoiceEnrollment = "api/v1/enrollment"
    private let methodVoiceMatching = "api/v1/authentication"
    private let liveness_threshold: Double = 0.5
    
    // TODO: Check what is this?
    
    private var imageToken = " "
    private var OCRToken = " "
    private var bestImageBase64: String = " "
    private var bestImageData: Data = Data()
    private var encodedReference: String = " "
    private var encodedProbe: Data = Data()
    private var ocr: [String: String] = [:]
    private var audios: [Data]?
    private var audioTemplate: String?
    private var generatedQrImage: UIImage = UIImage()
    private var bestImageTokenize: String = " "
    
    private var tokenFaceImage: String = " "
    private var documentFaceImageMapTokenized: String = " "
    private var base64FaceImage: String = " "
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

// MARK: - Inputs
extension MainVM {
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
        SDKManager.shared.newOperation(operationType: .ONBOARDING, customerId: SdkConfigurationManager.customerId, output: { sdkResult in
            self.log(msg: sdkResult.data != nil ? "New Operation with ID: \(sdkResult.data)": "ERROR: \(sdkResult.errorType)")
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
        guard let imageData = selphiResult.data?.bestImageData
        else
        {
            self.log(msg: "bestImage is nil")
            return
        }
        self.bestImageData = imageData
        
        self.bestImageBase64 = imageData.base64EncodedString()
        self.bestImageTokenize = selphiResult.data?.bestImageTokenized ?? " "
        
        self.log(msg: "Image correctly fetched")
    }
    
    func selphID(configuration: SelphIDConfigurationData) {
        SDKManager.shared.launchSelphId(setTracking: true, viewController: viewController, selphIDConfigurationData: configuration, output:  { selphIDResult in
            guard selphIDResult.errorType == .NO_ERROR else {
                self.log(msg: "\(selphIDResult.errorType)")
                return
            }
            
            guard let result = selphIDResult.data?.ocrResults else {
                self.log(msg: "ocrResults is nil")
                return
            }
            
            guard let imageData = selphIDResult.data?.faceImageData
            else
            {
                self.log(msg: "imageData is nil")
                return
            }
            
            self.ocr = Dictionary(uniqueKeysWithValues: result.flatMap { (key, value) -> (String, String)? in
                return (key, value)
            })
            self.tokenFaceImage = selphIDResult.data?.tokenFaceImage ?? ""
            self.base64FaceImage = imageData.base64EncodedString()
            self.saveNfcParameters(data: selphIDResult.data)
            
            self.log(msg: String(result.count))
        })
    }
    
    func nfc() {
        SDKManager.shared.launchNfc(setTracking: true, viewController: viewController, nfcConfigurationData: SdkConfigurationManager.nfcConfiguration, output: { nfcResult in
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
            self.log(msg: "QRReader OK: " + result.description)
        })
    }
    
    func launchPhacturas(configuration: InvoiceCaptureConfigurationData) {
        // swiftlint:disable all
        SDKManager.shared.launchPhacturas(setTracking: true, viewController: viewController, invoiceCaptureConfigurationData: configuration, output: { phacturasResult in
            guard phacturasResult.errorType == .NO_ERROR else {
                self.log(msg: "\(phacturasResult.errorType)")
                return
            }
            
            guard let result = phacturasResult.data
            else
            {
                self.log(msg: "Phacturas KO")
                return
            }
            self.log(msg: "Phacturas OK: " + String(result.scannedDocs.count))
        })
    }
    
//    func launchCaptureCUE(configuration: FileUploaderConfigurationData) {
//        // swiftlint:disable all
//        SDKManager.shared.launchCaptureCUE(setTracking: true, viewController: viewController, fileUploaderConfigurationData: configuration, output: { captureResult in
//            guard captureResult.errorType == .NO_ERROR else {
//                self.log(msg: "\(captureResult.errorType)")
//                return
//            }
//            
//            guard let result = captureResult.data
//            else
//            {
//                self.log(msg: "Capture KO")
//                return
//            }
//            self.log(msg: "Capture OK: " + String(result.documentImages.count))
//        })
//    }
    
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
    
    func videoCall(configuration: VideoCallConfigurationData){
        SDKManager.shared.launchVideoCall(data: configuration, setTracking: true, viewController: viewController, output: { videocallResult in
            if videocallResult.errorType == .NO_ERROR {
                self.log(msg: "Status OK \(videocallResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(videocallResult.errorType)")
            }
        })
    }
    
    func hangout() {
        SDKManager.shared.hangoutVideoCall()
    }
    
    func gallery(configuration: PhotoFromGalleryConfigurationData) {
        SDKManager.shared.launchGallery(data: configuration, setTracking: true, viewController: viewController, output: { galleryResult in
            if galleryResult.errorType == .NO_ERROR {
                self.log(msg: "Status OK \(galleryResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(galleryResult.errorType)")
            }
        })
    }
    
    func videoId(configuration: VideoIDConfigurationData) {
        SDKManager.shared.launchVideoId(data: configuration, setTracking: true, viewController: viewController, output: { videoIdResult in
            if videoIdResult.errorType == .NO_ERROR {
                self.bestImageTokenize = videoIdResult.data?.faceImageTokenized ?? ""
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
                self.bestImageTokenize = videoIdResult.data?.faceImageTokenized ?? ""
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
        SDKManager.shared.launchGenerateRawTemplate(data: bestImageData)
    }
    
    func startVideoRecording() {
        SDKManager.shared.launchVideoRecording(viewController: viewController)
    }
    
    func stopVideoRecording() {
        SDKManager.shared.stopVideoRecording()
    }
    
    // Never used
    func closeSession() {
        SDKManager.shared.closeSession()
    }
    
    func checkLivenessV5Token() {
        log(msg: "LAUNCH LIVENESS V5 TOKEN")
        SDKManager.shared.launchCheckLiveness(
            bestImage: bestImageTokenize,
            baseUrl: baseUrlV5,
            methodPassiveLivenesTracking: methodPassiveLivenesTrackingToken,
            param: "tokenImage") {
                self.log(msg: $0)
            }
    }
    
    func checkAuthDocFaceToken() {
        log(msg: "LAUNCH AUTH DOC FACE TOKEN")
        
        print("tokenFaceImage: \(tokenFaceImage)")
        print("bestImageTokenize: \(bestImageTokenize)")
        
        SDKManager.shared.launchMatchingFacial(
            faceParam1: documentFaceImageMapTokenized,
            faceParam2: bestImageTokenize,
            baseUrl: baseUrlV5,
            methodAuth: methodAuthenticateDocumentFacialToken,
            param1: "documentTemplate",
            param2: "faceTemplate1") {
                self.log(msg: $0)
            }
    }
    
    func checkAuthV5Token() {
        log(msg: "LAUNCH AUTH V5 TOKEN")
        SDKManager.shared.launchMatchingFacial(
            faceParam1: tokenFaceImage,
            faceParam2: bestImageTokenize,
            baseUrl: baseUrlV5,
            methodAuth: methodAuthenticateFacialToken,
            param1: "faceTemplate1",
            param2: "faceTemplate2") {
                self.log(msg: $0)
            }
    }
    
    func checkLivenessV5Image() {
        log(msg: "LAUNCH LIVENESS V5 IMAGE")
        SDKManager.shared.launchCheckLiveness(
            bestImage: bestImageBase64,
            baseUrl: baseUrlV5,
            methodPassiveLivenesTracking: methodPassiveLivenesTrackingImage,
            param: "image") {
                self.log(msg: $0)
            }
    }
    
    func checkAuthV5Image() {
        log(msg: "LAUNCH AUTH V5 IMAGE")
        SDKManager.shared.launchMatchingFacial(
            faceParam1: base64FaceImage,
            faceParam2: bestImageBase64,
            baseUrl: baseUrlV5,
            methodAuth: methodAuthenticateFacialImage,
            param1: "image1",
            param2: "image2") {
                self.log(msg: $0)
            }
    }
    
    func checkLivenessV6Token() {
        log(msg: "LAUNCH LIVENESS V6 TOKEN")
        SDKManager.shared.launchCheckLiveness(
            bestImage: bestImageTokenize,
            baseUrl: baseUrlV6,
            methodPassiveLivenesTracking: methodPassiveLivenesTrackingToken,
            param: "tokenImage") {
                self.log(msg: $0)
            }
    }
    
    func checkAuthV6Token() {
        log(msg: "LAUNCH AUTH V6 TOKEN")
        SDKManager.shared.launchMatchingFacial(
            faceParam1: tokenFaceImage,
            faceParam2: bestImageTokenize,
            baseUrl: baseUrlV6,
            methodAuth: methodAuthenticateFacialToken,
            param1: "faceTemplate1",
            param2: "faceTemplate2") {
                self.log(msg: $0)
            }
    }
    
    func checkLivenessV6Image() {
        log(msg: "LAUNCH LIVENESS V6 IMAGE")
        SDKManager.shared.launchCheckLiveness(
            bestImage: bestImageBase64,
            baseUrl: baseUrlV6,
            methodPassiveLivenesTracking: methodPassiveLivenesTrackingImage,
            param: "image") {
                self.log(msg: $0)
            }
    }
    
    func checkAuthV6Image() {
        log(msg: "LAUNCH AUTH V6 IMAGE")
        SDKManager.shared.launchMatchingFacial(
            faceParam1: base64FaceImage,
            faceParam2: bestImageBase64,
            baseUrl: baseUrlV6,
            methodAuth: methodAuthenticateFacialImage,
            param1: "image1",
            param2: "image2") {
                self.log(msg: $0)
            }
    }
    
    func checkAuthV5ImageToken() {
        log(msg: "LAUNCH AUTH V5 IMAGE/TOKEN")
        SDKManager.shared.launchMatchingFacial(
            faceParam1: bestImageBase64,
            faceParam2: bestImageTokenize,
            baseUrl: baseUrlV5,
            methodAuth: methodAuthenticateFacialImageToken,
            param1: "image1",
            param2: "faceTemplate1") {
                self.log(msg: $0)
            }
    }
    
    func checkAuthV6ImageToken() {
        log(msg: "LAUNCH AUTH V6 IMAGE/TOKEN")
        SDKManager.shared.launchMatchingFacial(
            faceParam1: bestImageBase64,
            faceParam2: bestImageTokenize,
            baseUrl: baseUrlV6,
            methodAuth: methodAuthenticateFacialImageToken,
            param1: "image1",
            param2: "faceTemplate1") {
                self.log(msg: $0)
            }
    }
    
    private func saveNfcParameters(data: SelphIDResult?) {
        guard let data else { return }
        
        PrefManager.set(data.getNfcKey(), forKey: .KEY_NFC_SUPPORT_NUMBER)
        PrefManager.set(data.getBirthDate(), forKey: .KEY_NFC_BIRTH_DATE)
        PrefManager.set(data.getExpiryDate(), forKey: .KEY_NFC_EXPIRATION_DATE)
    }
}
