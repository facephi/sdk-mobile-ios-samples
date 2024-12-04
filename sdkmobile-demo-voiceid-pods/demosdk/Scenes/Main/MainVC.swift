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
        case setupEnvironment = 0, newOperation
        case initFlow = 10, flowNextStep, flowCancel
        case checkLiveness = 20, checkFaceAuth
        case selphi = 30, selphid, nfc, launchPhacturas, videoCall, videoId, signatureSelphi, signatureVideoId
        case phingers = 40, matchPhingers
        case voiceId = 50, playAudios, voiceEnrollment, voiceMatching
        case generateQr = 60, launchQr
        case startVideoRecording = 70, stopVideoRecording
        case generateRawTemplate = 100, tokenize, license, clearLogs
    }

    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!
    @IBOutlet var btConfiguration: UIButton!

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
    
    private func loadAudiosView() {
        let vc = AudioPlayVC(numberOfAudios: SdkConfigurationManager.voiceIDConfiguration.phrases.count)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
        case .voiceId:
            viewModel.voiceId()
        case .playAudios:
            loadAudiosView()
        case .voiceEnrollment:
            viewModel.voiceEnrollment()
        case .voiceMatching:
            viewModel.voiceMatching()
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
