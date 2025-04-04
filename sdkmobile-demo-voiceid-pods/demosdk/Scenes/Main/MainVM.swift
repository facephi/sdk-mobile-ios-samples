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
    func voiceId()
    func getLicense()
    func closeSession()
    func voiceEnrollment()
    func voiceMatching()
}

protocol MainVMOutput {
    func show(msg: String)
    func showAlert(msg: String)
}

class MainVM {
   
    //VOICE Constants
    private let baseVoiceUrl = "https://external-voice-sdk.facephi.dev/"
    private let methodVoiceEnrollment = "api/v1/enrollment"
    private let methodVoiceMatching = "api/v1/authentication"
    private let liveness_threshold: Double = 0.5
    private var audios: [Data]?
    private var audioTemplate: String?

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
            enrollmentResult.validate_audios_result.forEach({
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


    // Never used
    func closeSession() {
        SDKManager.shared.closeSession()
    }
}
