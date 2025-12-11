//
//  EnvironmentVC.swift
//  demosdk
//
//  Created by Faustino Flores García on 15/6/22.
//

import core
import sdk
import UIKit

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
    @IBOutlet weak var scTrackingVersion: UISegmentedControl!

    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = EnvironmentVM(delegate: self)

        viewModel.getConfigurationData()
    }

    // MARK: - FUNC

    // MARK: - EVENTS
    @IBAction func saveClickListener(_ sender: Any) {
        let configurationData = ConfigurationDataModel(
            trackingVersion: TrackingVersion.allCases[scTrackingVersion.selectedSegmentIndex],
            customerId: tfCustomerId.text ?? "",
            operationType: OperationType.allCases[scOperationType.selectedSegmentIndex],
            locale: SdkLocale.allCases[scLocale.selectedSegmentIndex],
            flowID: tfFlowID.text ?? "",
            launch_main_background: segMainBackground.selectedSegmentIndex == 0
        )
        
        viewModel.setConfigurationData(configurationData)
    }
}

extension EnvironmentVC: EnvironmentVMOutput {
    func configurationDataIsGet(_ configurationData: ConfigurationDataModel) {
        scTrackingVersion.fill(withValues: TrackingVersion.allCases, defaultValue: configurationData.trackingVersion)
        lbGeneral.text = configurationData.version
        tfCustomerId.text = configurationData.customerId.isEmpty ? SdkConfigurationManager.email : configurationData.customerId
        tfFlowID.text = configurationData.flowID
        scOperationType.fill(withValues: OperationType.allCases, defaultValue: configurationData.operationType)
        scLocale.fill(withValues: SdkLocale.allCases, defaultValue: configurationData.locale)
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
