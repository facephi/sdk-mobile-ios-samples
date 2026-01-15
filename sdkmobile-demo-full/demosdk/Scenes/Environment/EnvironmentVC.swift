//
//  EnvironmentVC.swift
//  demosdk
//
//  Created by Faustino Flores García on 15/6/22.
//

import core
import sdk
import UIKit
import voiceIDComponent
import phingersTFComponent

class EnvironmentVC: UIViewController {
    // MARK: - VARS
    var completionHandler: (() -> Void)?
    private var viewModel: EnvironmentVMInput!

    // MARK: - OUTLET
    @IBOutlet var lbGeneral: UILabel!
    @IBOutlet var tfCustomerId: UITextField!
    @IBOutlet weak var tfFlowID: UITextField!
    @IBOutlet var scOperationType: UISegmentedControl!
    @IBOutlet weak var scLocale: UISegmentedControl!
    @IBOutlet weak var segMainBackground: UISegmentedControl!

    //NFC
    @IBOutlet var tfSupportNumber: UITextField!
    @IBOutlet var tfBirthDate: UITextField!
    @IBOutlet var tfExpirationDate: UITextField!
    @IBOutlet var tfIssuer: UITextField!
    @IBOutlet var scDocumentType: UISegmentedControl!
    
    //VOICE
    @IBOutlet weak var tfPhrases: UITextField!
    @IBOutlet weak var tfMinAudioLength: UITextField!
    @IBOutlet weak var tfMinSpeechLength: UITextField!
    @IBOutlet weak var tfMaxSilenceLength: UITextField!
    @IBOutlet weak var tfMinSnrDb: UITextField!
    @IBOutlet weak var tfMinAudioForAnalysis: UITextField!
    @IBOutlet weak var tfMinFeedbackTime: UITextField!
    @IBOutlet weak var segmentShowTutorial: UISegmentedControl!
    
    @IBOutlet weak var segReticleOrientation: UISegmentedControl!
    
    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        
        viewModel = EnvironmentVM(delegate: self)

        viewModel.getConfigurationData()
    }

    // MARK: - FUNC

    // MARK: - EVENTS
    @IBAction func saveClickListener(_ sender: Any) {
        let configurationData = ConfigurationDataModel(
            customerId: tfCustomerId.text ?? "",
            operationType: OperationType.allCases[scOperationType.selectedSegmentIndex],
            locale: SdkLocale.allCases[scLocale.selectedSegmentIndex],
            flowID: tfFlowID.text ?? "",
            nfc_supportNumber: tfSupportNumber.text ?? "",
            nfc_birthDate: tfBirthDate.text ?? "",
            nfc_expirationDate: tfExpirationDate.text ?? "",
            nfc_issuer: tfIssuer.text ?? "",
            nfc_documentType: NfcDocumentType.allCases[scDocumentType.selectedSegmentIndex],
            voice_id_phrases: tfPhrases.text ?? "",
            voice_id_min_audio_length: (tfMinAudioLength.text as? NSString)?.integerValue ?? 3000,
            voice_id_show_tutorial: segmentShowTutorial.selectedSegmentIndex == 0,
            voice_id_min_speech_length: (tfMinSpeechLength.text as? NSString)?.integerValue ?? 1000,
            voice_id_max_silence_length: (tfMaxSilenceLength.text as? NSString)?.integerValue ?? 500,
            voice_id_min_snr: (tfMinSnrDb.text as? NSString)?.integerValue ?? 10,
            voice_id_min_audio_for_analysis: (tfMinAudioForAnalysis.text as? NSString)?.integerValue ?? 100,
            voice_id_min_feedback_time: (tfMinFeedbackTime.text as? NSString)?.integerValue ?? 3000,
            launch_main_background: segMainBackground.selectedSegmentIndex == 0
        )
        
        viewModel.setConfigurationData(configurationData)
    }
}

extension EnvironmentVC: EnvironmentVMOutput {
    func configurationDataIsGet(_ configurationData: ConfigurationDataModel) {
        // GENERAL
        lbGeneral.text = configurationData.version
        tfCustomerId.text = configurationData.customerId.isEmpty ? SdkConfigurationManager.email : configurationData.customerId
        tfFlowID.text = configurationData.flowID
        scOperationType.fill(withValues: OperationType.allCases, defaultValue: configurationData.operationType)
        scLocale.fill(withValues: SdkLocale.allCases, defaultValue: configurationData.locale)

        // NFC
        tfSupportNumber.text = configurationData.nfc_supportNumber
        tfBirthDate.text = configurationData.nfc_birthDate
        tfExpirationDate.text = configurationData.nfc_expirationDate
        tfIssuer.text = configurationData.nfc_issuer
        scDocumentType.fill(withValues: NfcDocumentType.allCases, defaultValue: configurationData.nfc_documentType)
    }

    func configurationDataIsSet() {
        completionHandler?()
        
        _ = navigationController?.popViewController(animated: true)
    }
}

extension EnvironmentVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
    }
}
