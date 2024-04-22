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

class EnvironmentVC: UIViewController {
    // MARK: - VARS
    var completionHandler: (() -> Void)?
    private var viewModel: EnvironmentVMInput!

    // MARK: - OUTLET
    @IBOutlet var lbGeneral: UILabel!
    @IBOutlet var tfCustomerId: UITextField!
    @IBOutlet var scOperationType: UISegmentedControl!

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

    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = EnvironmentVM(delegate: self)

        viewModel.getConfigurationData()
    }

    // MARK: - FUNC

    // MARK: - EVENTS
    @IBAction func saveClickListener(_ sender: Any) {
        let configurationData = ConfigurationDataModel(customerId: tfCustomerId.text ?? "",
                                                       operationType: OperationType.allCases[scOperationType.selectedSegmentIndex],
                                                       nfc_supportNumber: tfSupportNumber.text ?? "",
                                                       nfc_birthDate: tfBirthDate.text ?? "",
                                                       nfc_expirationDate: tfExpirationDate.text ?? "",
                                                       nfc_issuer: tfIssuer.text ?? "",
                                                       nfc_documentType: NfcDocumentType.allCases[scDocumentType.selectedSegmentIndex])

        viewModel.setConfigurationData(configurationData)
        
        saveVoiceParams()
    }
    
    private func saveVoiceParams() {
        VoiceEnvironment.shared.update(
//            phrases: tfPhrases.text,
//            showTutorial: segmentShowTutorial.selectedSegmentIndex == 0,
            minSpeechLength: tfMinSpeechLength.text,
            maxSilenceLength: tfMaxSilenceLength.text,
            minSnrDb: tfMinSnrDb.text,
            minAudioForAnalysis: tfMinAudioForAnalysis.text,
            minAudioLength: tfMinAudioLength.text,
            minFeedbackTime: tfMinFeedbackTime.text
        )
    }
}

extension EnvironmentVC: EnvironmentVMOutput {
    func configurationDataIsGet(_ configurationData: ConfigurationDataModel) {
        // GENERAL
        lbGeneral.text = configurationData.version
        tfCustomerId.text = configurationData.customerId.isEmpty ? SdkConfigurationManager.email : configurationData.customerId
        scOperationType.fill(withValues: OperationType.allCases, defaultValue: configurationData.operationType)

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
