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
    func selphi()
    func selphID()
    func generateRawTemplate()
    func tokenizeExtradata()
    func nfc()
    func phingers()
    func videoId()
    func videoCall()
    func voiceId()
    func getLicense()
    func generateQr()
    func launchQr()
    func launchPhacturas()
    func closeSession()
    func checkLiveness()
    func checkAuth()
    func voiceEnrollment()
    func voiceMatching()
    func matchPhinger()
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
    func generateQr() {
        SDKManager.shared.launchQrGenerator(setTracking: true,
                                            viewController: viewController,
                                            qrGeneratorConfigurationData: SdkConfigurationManager.qrGeneratorConfiguration,
                                            output: { qrGeneratorResult in
            guard qrGeneratorResult.errorType == .NO_ERROR else {
                self.log(msg: qrGeneratorResult.errorType.rawValue)
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
            self.log(msg: sdkResult.data != nil ? "New Operation with ID: \(sdkResult.data)": "ERROR: NewOperation's data output is nil")
        })
    }

    func selphi() {
        SDKManager.shared.launchSelphi(setTracking: true, viewController: viewController, selphiConfigurationData: SdkConfigurationManager.selphiConfiguration, output: { selphiResult in
            guard selphiResult.errorType == .NO_ERROR else {
                self.log(msg: selphiResult.errorType.rawValue)
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
                self.log(msg: selphIDResult.errorType.rawValue)
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
    
    func nfc() {
        SDKManager.shared.launchNfc(setTracking: true, viewController: viewController, nfcConfigurationData: SdkConfigurationManager.nfcConfiguration, output: { nfcResult in
            guard nfcResult.errorType == .NO_ERROR else {
                self.log(msg: nfcResult.errorType.rawValue)
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
    
    func launchQr() {
        SDKManager.shared.launchQrReader(setTracking: true, viewController: viewController, qrReaderConfigurationData: SdkConfigurationManager.qrReaderConfiguration, output: { qrReaderResult in
            guard qrReaderResult.errorType == .NO_ERROR else {
                self.log(msg: qrReaderResult.errorType.rawValue)
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
    
    func launchPhacturas() {
        SDKManager.shared.launchPhacturas(setTracking: true, viewController: viewController, output: { phacturasResult in
            guard phacturasResult.errorType == .NO_ERROR else {
                self.log(msg: phacturasResult.errorType.rawValue)
                return
            }
            
            guard let result = phacturasResult.data
                    else
            {
                self.log(msg: "Phacturas KO")
                return
            }
            self.log(msg: "Phacturas OK: " + result.description)
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
    
    func phingers() {
//        SDKManager.shared.launchPhingers(setTracking: true, viewController: viewController, phingersConfigurationData: SdkConfigurationManager.phingersConfiguration, output: { phingersResult in
//            guard phingersResult.errorType == .NO_ERROR else {
//                self.log(msg: phingersResult.errorType.rawValue)
//                return
//            }
//            
//            if phingersResult.finishStatus == .STATUS_OK {
//                
//                if self.encodedReference.isEmpty && (phingersResult.data?.fingerprintTemplates.count)! > 0 {
//                    self.encodedReference = phingersResult.data?.fingerprintTemplates[1] ?? Data()
//                } else {
//                    self.encodedProbe = phingersResult.data?.processedFingerprintImages[1] ?? UIImage()
//                }
//    
//                self.log(msg: "Status OK")
//                print(phingersResult.finishStatus)
//            } else {
//                self.log(msg: phingersResult.errorType.rawValue)
//                print(phingersResult.errorType)
//            }
//        })
    }
    
    func videoCall() {
        SDKManager.shared.launchVideoCall(data: SdkConfigurationManager.videoCallConfiguration, setTracking: true, viewController: viewController, output: { videocallResult in
            if videocallResult.finishStatus == .STATUS_OK {
                self.log(msg: "Status OK \(videocallResult.finishStatus)")
            } else {
                self.log(msg: "Status KO \(videocallResult.errorType)")
            }
        })
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
    
    func voiceId() {
        SDKManager.shared.launchVoiceId(data: SdkConfigurationManager.voiceIDConfiguration ,setTracking: true, viewController: viewController, output: { voiceIdResult in
            if voiceIdResult.finishStatus == .STATUS_OK,
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
    
    func checkLiveness() {
        self.log(msg: SDKManager.shared.launchCheckLiveness(bestImage: bestImage,
                                                            extradata: SDKManager.shared.launchExtradata().data ?? "",
                                              baseUrl: baseUrl,
                                              methodPassiveLivenesTracking: methodPassiveLivenesTracking))
    }
    
    func checkAuth() {
        self.log(msg: SDKManager.shared.launchCheckAuth(tokenFaceImage: tokenFaceImage, bestImage: bestImage, extradata: extradataToken, baseUrl: baseUrl, methodAuth: methodAuthenticateFacial))
    }
    
    func voiceEnrollment() {
        SDKManager.shared.launchVoiceId(data: SdkConfigurationManager.voiceIDConfiguration, setTracking: true, viewController: viewController, output: { voiceIdResult in
            if voiceIdResult.finishStatus == .STATUS_OK,
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
            enrollmentResult.validate_audios_result?.forEach({
                validatedAudios.append("\($0.audio_position) - Result=\($0.result_code)")
            })
            self.log(msg: validatedAudios)
        })
    }
    
    func voiceMatching() {
        SDKManager.shared.launchVoiceId(data: SdkConfigurationManager.voiceIDConfiguration, setTracking: true, viewController: viewController, output: { voiceIdResult in
            if voiceIdResult.finishStatus == .STATUS_OK,
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
        SDKManager.shared.launchGenerateRawTemplate()
    }
    
    func matchPhinger(){
//        var configMatching = PhingersMatcherConfigurationData()
//        
//        configMatching.encodedReference = self.encodedReference
//        configMatching.encodedProbe = self.encodedProbe
//        configMatching.pyramidScale = [0.8, 1.0, 1.2]
//        configMatching.threshold = 34.0
//        
//        guard configMatching.encodedReference.isEmpty == true else {
//            self.log(msg: "Debe tener una huella de referencia")
//            return
//        }
//        
//        guard configMatching.encodedProbe.size.width > 0 else {
//            self.log(msg: "Debe tener una huella para comparar")
//            return
//        }
//        
//        SDKManager.shared.matchPhinger(setTracking: true, phingersMatcherConfigurationData: configMatching, output: { matchResult in
//            if matchResult.finishStatus == .STATUS_OK,
//               let result = matchResult.data{
//                self.log(msg: "Status OK \(matchResult.finishStatus) \(matchResult.data?.score)")
//            }else{
//                self.log(msg: "Status KO \(matchResult.errorType)")
//            }
//        })
    }

    // Never used
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
