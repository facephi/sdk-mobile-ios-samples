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
        case launchFlow = 1
        case clearLogs
    }

    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!

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
        case .launchFlow:
            viewModel.launchFlow()
        case .clearLogs:
            clearText()
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
