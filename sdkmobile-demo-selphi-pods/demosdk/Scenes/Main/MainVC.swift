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
        case setupEnvironment = 1, newOperation, checkLiveness, checkFaceAuth
        case selphi, selphid, generateRawTemplate,
             tokenize, license, clearLogs
    }

    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!
    @IBOutlet var btConfiguration: UIButton!

    // MARK: - VARS
    private var viewModel: MainVMInput!
    private let customViewsSwitch = UISwitch()

    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainVM(viewController: self, delegate: self)
        setupCustomViewsToggle()
    }

    private func setupCustomViewsToggle() {
        customViewsSwitch.isOn = SdkConfigurationManager.useDemoKmpCustomCameraOverlay
        customViewsSwitch.addTarget(self, action: #selector(customViewsSwitchChanged(_:)), for: .valueChanged)

        let label = UILabel()
        label.text = "KMP custom views"
        label.font = .systemFont(ofSize: 14)

        let stack = UIStackView(arrangedSubviews: [label, customViewsSwitch])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }

    @objc private func customViewsSwitchChanged(_ sender: UISwitch) {
        SdkConfigurationManager.useDemoKmpCustomCameraOverlay = sender.isOn
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
        case .setupEnvironment:
            break
        case .newOperation:
            viewModel.newOperation()
        case .selphi:
            viewModel.selphi()
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
