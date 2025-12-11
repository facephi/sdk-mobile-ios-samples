//
//  MainVC.swift
//  demosdk
//
//  Created by Faustino Flores García on 26/4/22.
//

import UIKit
import captureComponent
import selphiComponent
import selphidComponent

class MainVC: UIViewController {
    // MARK: - ENUM
    private enum ButtonTag: Int {
        case setupEnvironment = 0, newOperation
        case initFlow = 10, flowNextStep, flowCancel
        case selphid = 20, selphi
        case launchFileUploader = 30
        case startVideoRecording = 40, stopVideoRecording
        case launchExtractDocument = 50, launchIdentityValidation
        case launchDocumentValidationStart = 60, launchDocumentValidationStatus, launchDocumentValidationData
        case launchFinishTracking = 100
        case generateRawTemplate = 120, tokenize, license, clearLogs, closeSession
    }
    
    // MARK: - OUTLET
    @IBOutlet var lbLog: UITextView!
    @IBOutlet var btConfiguration: UIButton!
    
    // MARK: - VARS
    private var viewModel: MainVM!
    
    // MARK: - OVERRIDE
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = MainVM(viewController: self, delegate: self)
    }
    
    // MARK: - FUNC
    
    private func clearText() {
        show(msg: "")
    }
    
    func execute(action: @escaping () -> Void) {
        let executeOnMainThread: Bool = PrefManager.get(Bool.self, forKey: .KEY_LAUNCH_MAIN_BACKGROUND) ?? true
        
        let queue = executeOnMainThread ? DispatchQueue.main: DispatchQueue.global()
        queue.async {
            action()
        }
    }
    
    private func presentConfigComponent<T>(component: ConfigComponent, configType: T.Type, actionHandler: @escaping (T) -> Void) {
        DispatchQueue.main.async {
            let configVC = ConfigsComponentsVC()
            configVC.action = { config in
                if let typedConfig = config as? T {
                    actionHandler(typedConfig)
                }
            }
            configVC.component = component
            self.present(configVC, animated: true)
        }
    }
    
    // MARK: - EVENTS
    @IBAction func buttonClickListener(_ sender: Any) {
        guard let button = sender as? UIButton else {
            return
        }
        clearText()
        switch ButtonTag(rawValue: button.tag) {
        case .setupEnvironment:
            break
        case .newOperation:
            execute{
                self.viewModel.newOperation()
            }
        case .initFlow:
            execute{
                self.viewModel.initFlow()
            }
        case .flowNextStep:
            execute{
                self.viewModel.flowNextStep()
            }
        case .flowCancel:
            execute{
                self.viewModel.flowCancel()
            }
        case .launchIdentityValidation:
            execute{
                self.viewModel.launchIdentityValidation()
            }
        case .launchExtractDocument:
            execute{
                self.viewModel.launchExtractDocument()
            }
        case .launchDocumentValidationStart:
            execute{
                self.viewModel.launchDocumentValidationStart()
            }
        case .launchDocumentValidationStatus:
            execute{
                self.viewModel.launchDocumentValidationStatus()
            }
        case .launchDocumentValidationData:
            execute{
                self.viewModel.launchDocumentValidationData()
            }
        case .launchFinishTracking:
            self.presentConfigComponent(component: .FINISH_TRACKING, configType: FinishTrackingData.self) {
                self.viewModel.launchFinishTracking(configuration: $0)
            }
        case .selphi:
            self.presentConfigComponent(component: .SELPHI_COMPONENT, configType: SelphiConfigurationData.self) {
                self.viewModel.selphi(configuration: $0)
            }
        case .selphid:
            presentConfigComponent(component: .SELPHID_COMPONENT, configType: SelphIDConfigurationData.self) {
                self.viewModel.selphID(configuration: $0)
            }
        case .generateRawTemplate:
            execute{
                self.viewModel.generateRawTemplate()
            }
        case .tokenize:
            execute{
                self.viewModel.tokenizeExtradata()
            }
        case .license:
            execute{
                self.viewModel.getLicense()
            }
        case .launchFileUploader:
            presentConfigComponent(component: .FILE_UPLOADER_COMPONENT, configType: FileUploaderConfigurationData.self) {
                self.viewModel.launchFileUploader(configuration: $0)
            }
        case .startVideoRecording:
            execute{
                self.viewModel.startVideoRecording()
            }
        case .stopVideoRecording:
            execute{
                self.viewModel.stopVideoRecording()
            }
        case .clearLogs:
            execute{
                self.clearText()
            }
        case .closeSession:
            execute{
                self.viewModel.closeSession()
            }
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
