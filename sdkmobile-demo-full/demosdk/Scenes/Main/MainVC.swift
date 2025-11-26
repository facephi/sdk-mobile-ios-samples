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
import videocallComponent
import videoidComponent
import voiceIDComponent
import phingersTFComponent

class MainVC: UIViewController {
    // MARK: - ENUM
    private enum ButtonTag: Int {
        case setupEnvironment = 0, newOperation
        case initFlow = 10, flowNextStep, flowCancel
        case checkLiveness = 20, checkFaceAuth
        case selphid = 30, nfc, videoId, signatureVideoId, launchPhacturas, gallery, launchCaptureCUE
        case selphi = 40, signatureSelphi
        case phingersTF = 50
        case voiceId = 60, playAudios, voiceEnrollment, voiceMatching
        case generateQr = 70, launchQr
        case startVideoRecording = 80, stopVideoRecording
        case videoCall = 90, hangout
        case checkLivenessV5Token = 100, checkAuthV5Token, checkLivenessV5Image, checkAuthV5Image, checkLivenessV6Token, checkAuthV6Token, checkLivenessV6Image, checkAuthV6Image
        case checkAuthMapDocFaceToken = 108, checkAuthV5ImageToken, checkAuthV6ImageToken
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
                    actionHandler(typedConfig)
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
        case .flowNextStep:
            execute{
                self.viewModel.flowNextStep()
            }
        case .flowCancel:
            execute{
                self.viewModel.flowCancel()
            }
        case .checkLivenessV5Token:
            execute{
                self.viewModel.checkLivenessV5Token()
            }
        case .checkAuthV5Token:
            execute{
                self.viewModel.checkAuthV5Token()
            }
        case .checkLivenessV5Image:
            execute{
                self.viewModel.checkLivenessV5Image()
            }
        case .checkAuthV5Image:
            execute{
                self.viewModel.checkAuthV5Image()
            }
        case .checkLivenessV6Token:
            execute{
                self.viewModel.checkLivenessV6Token()
            }
        case .checkAuthV6Token:
            execute{
                self.viewModel.checkAuthV6Token()
            }
        case .checkLivenessV6Image:
            execute{
                self.viewModel.checkLivenessV6Image()
            }
        case .checkAuthV6Image:
            execute{
                self.viewModel.checkAuthV6Image()
            }
        case .checkAuthV5ImageToken:
            execute{
                self.viewModel.checkAuthV5ImageToken()
            }
        case .checkAuthV6ImageToken:
            execute{
                self.viewModel.checkAuthV6ImageToken()}
        case .selphi:
            self.presentConfigComponent(component: .SELPHI_COMPONENT, configType: SelphiConfigurationData.self) {
                self.viewModel.selphi(configuration: $0)
            }
        case .selphid:
            presentConfigComponent(component: .SELPHID_COMPONENT, configType: SelphIDConfigurationData.self) {
                self.viewModel.selphID(configuration: $0)
            }
        case .nfc:
            execute{
                self.viewModel.nfc()
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
        case .gallery:
            presentConfigComponent(component: .GALLERY_COMPONENT, configType: PhotoFromGalleryConfigurationData.self){
                self.viewModel.gallery(configuration: $0)
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
        case .launchPhacturas:
            presentConfigComponent(component: .CAPTURE_COMPONENT, configType: InvoiceCaptureConfigurationData.self) {
                self.viewModel.launchPhacturas(configuration: $0)
            }
//        case .launchCaptureCUE:
//            presentConfigComponent(component: .DOCUMENT_CAPTURE_COMPONENT, configType: FileUploaderConfigurationData.self) {
//                self.viewModel.launchCaptureCUE(configuration: $0)
//            }
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
        case .checkAuthMapDocFaceToken:
            execute {
                self.viewModel.checkAuthDocFaceToken()
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
