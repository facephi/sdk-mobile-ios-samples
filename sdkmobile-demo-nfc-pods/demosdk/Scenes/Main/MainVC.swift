//
//  MainVC.swift
//  demosdk
//
//  Created by Faustino Flores García on 26/4/22.
//

import UIKit

class MainVC: UIViewController {
    // MARK: - ENUM
    private enum ButtonTag: Int {
        case newOperation = 1, nfc, closesession
    }

    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!
    @IBOutlet var ImageOne: UIImageView!
    
    @IBOutlet var tfSupportNumber: UITextField!
    @IBOutlet var tfBirthDate: UITextField!
    @IBOutlet var tfExpirationDate: UITextField!
    @IBOutlet var tfIssuer: UITextField!
    
    // MARK: - VARS
    private var viewModel: MainVMInput!
    
    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()

        LocationManager.shared.checkLocationPermissions(viewController: self)
        viewModel = MainVM(viewController: self, delegate: self)
 
    }
    
    // MARK: - FUNC

    private func clearText() {
        show(msg: "")
        
    }

    // MARK: - EVENTS
    // swiftlint:disable cyclomatic_complexity
    @IBAction func buttonClickListener(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        clearText()
        switch ButtonTag(rawValue: button.tag) {
        case .newOperation:
            viewModel.newOperation()
        case .nfc:
            viewModel.nfc(tfSupportNumber: tfSupportNumber.text ?? "", tfBirthDate: tfBirthDate.text ?? "", tfExpirationDate: tfExpirationDate.text ?? "", tfIssuer: tfIssuer.text ?? "")
        case .closesession:
            viewModel.closeSession()
        default:
            break
        }
    }
}

extension MainVC: MainVMOutput {
    
    func show(msg: String) {
        DispatchQueue.main.async {
            self.lbLog.text = msg
        }
    }
}
