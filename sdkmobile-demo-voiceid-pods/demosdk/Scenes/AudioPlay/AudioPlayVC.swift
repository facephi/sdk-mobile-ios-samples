//
//  AudioPlayVC.swift
//  demosdk
//
//  Created by Carlos Cantos on 12/7/23.
//

import UIKit
import core
import AVFoundation

class AudioPlayVC: UIViewController {
    private var audioPlayView: AudioPlayView?
    private var numberOfAudios: Int = 0
    static var audioPlayer: AVAudioPlayer!
    
    public init(numberOfAudios: Int) {
        self.numberOfAudios = numberOfAudios
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addAudioPlayView()
    }
    
    private func addAudioPlayView() {
        audioPlayView = UIView.fromNib()
        audioPlayView?.addSubviewWithConstraints(attributes: [.top, .leading, .bottom, .trailing], parentView: view)
        audioPlayView?.delegate = self
        audioPlayView?.configure(numberOfAudios: getNumberOfAudios())
    }
    
    private func getNumberOfAudios() -> Int {
        do {
            let directoryFiles = try FileManager.default.contentsOfDirectory(at: SdkConfigurationManager.audiosDirectory, includingPropertiesForKeys: nil)
            return directoryFiles.count
        } catch {
            print("Error while obtaining audios")
            return 0
        }
    }
}

extension AudioPlayVC: AudioPlayViewDelegate {
    func backButtonTouchUpInside() {
        self.dismiss(animated: true)
    }
    
    func playAudioButtonTouchUpInside(tag: Int) {
        let audioFileName = SdkConfigurationManager.audiosDirectory.appendingPathComponent("audio" + String(tag) + ".wav")
        do {
           try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
           try AVAudioSession.sharedInstance().setActive(true)
//            let player = try AVAudioPlayer(contentsOf: audioFileName)
            AudioPlayVC.audioPlayer = try AVAudioPlayer(contentsOf: audioFileName, fileTypeHint: AVFileType.wav.rawValue)
            AudioPlayVC.audioPlayer.play()
            
            try print("Number of audios: " + String(FileManager.default.contentsOfDirectory(at: SdkConfigurationManager.audiosDirectory, includingPropertiesForKeys: nil).count))
           } catch {
               let alert = UIAlertController(title: "Error", message: "No existe el audio", preferredStyle: UIAlertController.Style.alert)
               alert.addAction(UIAlertAction(title: "Volver", style: UIAlertAction.Style.default, handler: nil))
               self.present(alert, animated: true, completion: nil)
           }
    }
}
