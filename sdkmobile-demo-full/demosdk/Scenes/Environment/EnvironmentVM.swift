//
//  EnvironmentVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 15/6/22.
//

import core
import sdk
import Foundation

protocol EnvironmentVMInput {
    func getConfigurationData()
    func setConfigurationData(_ configurationData: ConfigurationDataModel)
}

protocol EnvironmentVMOutput {
    func configurationDataIsGet(_ configurationData: ConfigurationDataModel)
    func configurationDataIsSet()
}

class EnvironmentVM {
    // MARK: - VARS
    private var delegate: EnvironmentVMOutput!

    init(delegate: EnvironmentVMOutput) {
        self.delegate = delegate
    }
}

extension EnvironmentVM: EnvironmentVMInput {
    func setConfigurationData(_ configurationData: ConfigurationDataModel) {
        PrefManager.set(configurationData.customerId, forKey: .KEY_CUSTOMER_ID)
        PrefManager.set(configurationData.flowID, forKey: .KEY_FLOW_ID)
        PrefManager.set(configurationData.operationType.rawValue, forKey: .KEY_OPERATION_TYPE)
        PrefManager.set(configurationData.locale.rawValue, forKey: .KEY_LOCALE)

        PrefManager.set(configurationData.nfc_supportNumber, forKey: .KEY_NFC_SUPPORT_NUMBER)
        PrefManager.set(configurationData.nfc_birthDate, forKey: .KEY_NFC_BIRTH_DATE)
        PrefManager.set(configurationData.nfc_expirationDate, forKey: .KEY_NFC_EXPIRATION_DATE)
        PrefManager.set(configurationData.nfc_issuer, forKey: .KEY_NFC_ISSUER)
        PrefManager.set(configurationData.nfc_documentType.rawValue, forKey: .KEY_NFC_DOCUMENT_TYPE)
        
        PrefManager.set(configurationData.voice_id_show_tutorial, forKey: .KEY_VOICE_ID_SHOW_TUTORIAL)
        PrefManager.set(configurationData.voice_id_phrases, forKey: .KEY_VOICE_ID_PHRASES)
        PrefManager.set(configurationData.voice_id_min_audio_length, forKey: .KEY_VOICE_ID_MIN_AUDIO_LENGTH)
        PrefManager.set(configurationData.voice_id_min_speech_length, forKey: .KEY_VOICE_ID_MIN_SPEECH_LENGTH)
        PrefManager.set(configurationData.voice_id_max_silence_length, forKey: .KEY_VOICE_ID_MAX_SILENCE_LENGTH)
        PrefManager.set(configurationData.voice_id_min_snr, forKey: .KEY_VOICE_ID_MIN_SNR)
        PrefManager.set(configurationData.voice_id_min_audio_for_analysis, forKey: .KEY_VOICE_ID_MIN_AUDIO_FOR_ANALYSIS)
        PrefManager.set(configurationData.voice_id_min_feedback_time, forKey: .KEY_VOICE_ID_MIN_FEEDBACK_TIME)
        
        PrefManager.set(configurationData.launch_main_background, forKey: .KEY_LAUNCH_MAIN_BACKGROUND)
                
        delegate.configurationDataIsSet()
    }

    func getConfigurationData() {
        delegate.configurationDataIsGet(ConfigurationDataModel())
    }
}

struct ConfigurationDataModel {
    let version: String
    
    let customerId: String
    let flowID: String
    
    let operationType: OperationType
    let locale: SdkLocale
    let nfc_supportNumber: String
    let nfc_birthDate: String
    let nfc_expirationDate: String
    let nfc_issuer: String
    let nfc_documentType: NfcDocumentType
    
    let voice_id_phrases: String
    let voice_id_min_audio_length: Int
    let voice_id_show_tutorial: Bool
    let voice_id_min_speech_length: Int
    let voice_id_max_silence_length: Int
    let voice_id_min_snr: Int
    let voice_id_min_audio_for_analysis: Int
    let voice_id_min_feedback_time: Int

    let launch_main_background: Bool
    
    init(customerId: String,
         operationType: OperationType,
         locale: SdkLocale,
         flowID: String,
         nfc_supportNumber: String,
         nfc_birthDate: String,
         nfc_expirationDate: String,
         nfc_issuer: String,
         nfc_documentType: NfcDocumentType,
         voice_id_phrases: String,
         voice_id_min_audio_length: Int,
         voice_id_show_tutorial: Bool,
         voice_id_min_speech_length: Int,
         voice_id_max_silence_length: Int,
         voice_id_min_snr: Int,
         voice_id_min_audio_for_analysis: Int,
         voice_id_min_feedback_time: Int,
         launch_main_background: Bool)
         
    {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        
        self.version = "General - Versión: \(version) (\(build))"
        self.customerId = customerId
        self.operationType = operationType
        self.locale = locale
        self.flowID = flowID
        
        self.nfc_supportNumber = nfc_supportNumber
        self.nfc_birthDate = nfc_birthDate
        self.nfc_expirationDate = nfc_expirationDate
        self.nfc_issuer = nfc_issuer
        self.nfc_documentType = nfc_documentType
        
        self.voice_id_phrases = voice_id_phrases
        self.voice_id_min_audio_length = voice_id_min_audio_length
        self.voice_id_show_tutorial = voice_id_show_tutorial
        self.voice_id_min_speech_length = voice_id_min_speech_length
        self.voice_id_max_silence_length = voice_id_max_silence_length
        self.voice_id_min_snr = voice_id_min_snr
        self.voice_id_min_audio_for_analysis = voice_id_min_audio_for_analysis
        self.voice_id_min_feedback_time = voice_id_min_feedback_time
        
        self.launch_main_background = launch_main_background
    }
    
    init() {
        self.init(
            customerId: PrefManager.get(String.self, forKey: .KEY_CUSTOMER_ID) ?? "",
            operationType: PrefManager.get(.ONBOARDING, forKey: .KEY_OPERATION_TYPE),
            locale: PrefManager.get(.es, forKey: .KEY_LOCALE),
            flowID: PrefManager.get(String.self, forKey: .KEY_FLOW_ID) ?? "",
            nfc_supportNumber: PrefManager.get(String.self, forKey: .KEY_NFC_SUPPORT_NUMBER) ?? "",
            nfc_birthDate: PrefManager.get(String.self, forKey: .KEY_NFC_BIRTH_DATE) ?? "",
            nfc_expirationDate: PrefManager.get(String.self, forKey: .KEY_NFC_EXPIRATION_DATE) ?? "",
            nfc_issuer: PrefManager.get(String.self, forKey: .KEY_NFC_ISSUER) ?? "",
            nfc_documentType: PrefManager.get(.ID_CARD, forKey: .KEY_NFC_DOCUMENT_TYPE),
            voice_id_phrases: PrefManager.get(String.self, forKey: .KEY_VOICE_ID_PHRASES) ?? "Facephi Biometria",
            voice_id_min_audio_length: PrefManager.get(Int.self, forKey: .KEY_VOICE_ID_MIN_AUDIO_LENGTH) ?? 3000,
            voice_id_show_tutorial: PrefManager.get(Bool.self, forKey: .KEY_VOICE_ID_SHOW_TUTORIAL) ?? true,
            voice_id_min_speech_length: PrefManager.get(Int.self, forKey: .KEY_VOICE_ID_MIN_SPEECH_LENGTH) ?? 1000,
            voice_id_max_silence_length: PrefManager.get(Int.self, forKey: .KEY_VOICE_ID_MAX_SILENCE_LENGTH) ?? 500,
            voice_id_min_snr: PrefManager.get(Int.self, forKey: .KEY_VOICE_ID_MIN_SNR) ?? 10,
            voice_id_min_audio_for_analysis: PrefManager.get(Int.self, forKey: .KEY_VOICE_ID_MIN_AUDIO_FOR_ANALYSIS) ?? 100,
            voice_id_min_feedback_time: PrefManager.get(Int.self, forKey: .KEY_VOICE_ID_MIN_FEEDBACK_TIME) ?? 3000,
            launch_main_background: PrefManager.get(Bool.self, forKey: .KEY_LAUNCH_MAIN_BACKGROUND) ?? true
        )
    }
}

enum NfcDocumentType: String, CaseIterable {
    case ID_CARD
    case PASSPORT
}

enum SdkLocale: String, CaseIterable {
    case es
    case en
    case pt
    case ptBR = "pt-BR"
    case ca
}
