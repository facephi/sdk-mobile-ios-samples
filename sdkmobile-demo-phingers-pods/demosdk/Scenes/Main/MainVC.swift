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
        case newOperation = 1, phingers, matchPhinger, license, clearLogs
    }

    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!
    @IBOutlet var btConfiguration: UIButton!

    @IBOutlet weak var segReticleOrientation: UISegmentedControl!
    
    // MARK: - VARS
    private var viewModel: MainVMInput!

    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()
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
        case .phingers:
            viewModel.phingers(reticleOrientation: segReticleOrientation.selectedSegmentIndex)
        case .matchPhinger:
            viewModel.matchPhinger()
        case .license:
            viewModel.getLicense()
        case .clearLogs:
            clearText()
        default:
            break
        }
    }
}

extension MainVC: MainVMOutput {
    func showAlert(msg: String) {
        let alertController = UIAlertController(title: "",
                                                message: msg,
                                                preferredStyle: .alert)

        let okAction = UIAlertAction(title: "ok", style: .default, handler: { _ in
            exit(0)
        })
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }
    func show(msg: String) {
        DispatchQueue.main.async {
            self.lbLog.text = msg
        }
    }
}
