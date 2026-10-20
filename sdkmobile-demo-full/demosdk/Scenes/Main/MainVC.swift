//
//  MainVC.swift
//  demosdk
//
//  Created by Faustino Flores García on 26/4/22.
//

import UIKit
import captureComponent
import nfcComponent
import phingersTFComponent
import selphiComponent
import selphidComponent
import videocallComponent
import videoidComponent
import videoRecordingComponent
import voiceIDComponent
import termsConditionsComponent

class MainVC: UIViewController {
    // MARK: - ENUM
    private enum ButtonTag: Int {
        case setupEnvironment = 0, newOperation
        case initFlow = 10, initFlowOffline, flowNextStep, cancelLaunch
        case enableVolumeUpCancel = 15, disableVolumeUpCancel
        case checkLiveness = 20, checkFaceAuth
        case selphid = 30, nfc, videoId, signatureVideoId, launchCaptureCUE = 36
        case selphi = 40, signatureSelphi
        case phingersTF = 50
        case voiceId = 60, playAudios, voiceEnrollment, voiceMatching
        case generateQr = 70, launchQr
        case startVideoRecording = 80, stopVideoRecording
        case videoCall = 90, hangout
        case launchExtractDocument = 100, launchIdentityValidation
        case launchDocumentValidationStart = 110, launchDocumentValidationStatus, launchDocumentValidationData
        case launchFinishTracking = 120, launchTermsConditions = 125
        case generateRawTemplate = 130, tokenize, license, clearLogs, closeSession
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
    
    private func loadAudiosView() {
        let vc = AudioPlayVC(numberOfAudios: SdkConfigurationManager.voiceIDConfiguration.phrases.count)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    
    func execute(action: @escaping () -> Void) {
        var executeOnMainThread: Bool = PrefManager.get(Bool.self, forKey: .KEY_LAUNCH_MAIN_BACKGROUND) ?? true
        
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
                    self.execute {
                        actionHandler(typedConfig)
                    }
                }
            }
            configVC.component = component
            self.present(configVC, animated: true)
        }
    }
    
    // MARK: - EVENTS
    // swiftlint:disable all
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
            execute{
                self.viewModel.newOperation()
            }
        case .initFlow:
            execute{
                self.viewModel.initFlow()
            }
        case .initFlowOffline:
            execute{
                self.viewModel.initFlowOffline()
            }
        case .flowNextStep:
            execute{
                self.viewModel.flowNextStep()
            }
        case .cancelLaunch:
            execute{
                self.viewModel.cancelLaunch()
            }
        case .enableVolumeUpCancel:
            DispatchQueue.main.async {
                self.viewModel.enableVolumeUpCancelLaunch()
            }
        case .disableVolumeUpCancel:
            DispatchQueue.main.async {
                self.viewModel.disableVolumeUpCancelLaunch()
            }
        case .selphi:
            self.presentConfigComponent(component: .SELPHI_COMPONENT, configType: SelphiConfigurationData.self) {
                self.viewModel.selphi(configuration: $0)
            }
        case .selphid:
            presentConfigComponent(component: .SELPHID_COMPONENT, configType: SelphIDConfigurationData.self) {
                self.viewModel.selphID(configuration: $0)
            }
        case .nfc:
            presentConfigComponent(component: .NFC_COMPONENT, configType: NfcConfigurationData.self) {
                self.viewModel.nfc(configuration: $0)
            }
        case .phingersTF:
            presentConfigComponent(component: .PHINGER_COMPONENT, configType: PhingersConfigurationData.self) {
                self.viewModel.phingers(configuration: $0)
            }
        case .videoCall:
            presentConfigComponent(component: .VIDEOCALL_COMPONENT, configType: VideoCallConfigurationData.self) {
                self.viewModel.videoCall(configuration: $0)
            }
        case .hangout:
            execute{
                self.viewModel.hangout()
            }
        case .videoId:
            presentConfigComponent(component: .VIDEOID_COMPONENT, configType: VideoIDConfigurationData.self) {
                self.viewModel.videoId(configuration: $0)
            }
        case .signatureSelphi:
            presentConfigComponent(component: .SELPHI_COMPONENT, configType: SelphiConfigurationData.self) {
                self.viewModel.signatureSelphi(configuration: $0)
            }
        case .signatureVideoId:
            presentConfigComponent(component: .VIDEOID_COMPONENT, configType: VideoIDConfigurationData.self) {
                self.viewModel.signatureVideoId(configuration: $0)
            }
        case .voiceId:
            presentConfigComponent(component: .VOICE_COMPONENT, configType: VoiceConfigurationData.self) {
                self.viewModel.voiceId(configuration: $0)
            }
        case .playAudios:
            execute{
                self.loadAudiosView()
            }
        case .voiceEnrollment:
            execute{
                self.viewModel.voiceEnrollment()
            }
        case .voiceMatching:
            execute{
                self.viewModel.voiceMatching()
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
        case .generateQr:
            execute{
                self.viewModel.generateQr()
            }
        case .launchQr:
            presentConfigComponent(component: .QR_COMPONENT, configType: QrCaptureConfigurationData.self) {
                self.viewModel.launchQr(configuration: $0)
            }
        case .launchCaptureCUE:
            presentConfigComponent(component: .DOCUMENT_CAPTURE_COMPONENT, configType: FileUploaderConfigurationData.self) {
                self.viewModel.launchCaptureCUE(configuration: $0)
            }
        case .startVideoRecording:
            presentConfigComponent(component: .START_VIDEO_RECORDING_COMPONENT, configType: VideoRecordingConfigurationData.self) {
                self.viewModel.startVideoRecording(configuration: $0)
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
        case .launchIdentityValidation:
            execute{
                self.viewModel.launchIdentityValidation()
            }
        case .launchExtractDocument:
            execute{
                self.viewModel.launchExtractDocument()
            }
        case .launchTermsConditions:
            presentConfigComponent(component: .TERMS_CONDITIONS_COMPONENT, configType: TermsConditionsConfigurationData.self) {
                self.viewModel.launchTermsConditions(configuration: $0)
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
