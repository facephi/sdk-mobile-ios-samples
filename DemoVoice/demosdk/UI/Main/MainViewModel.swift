//
//  MainViewModel.swift
//  demosdk
//
//  Port of Android MainViewModel.kt + media/AppMediaPlayer.kt (DemoVoice).
//

import AVFoundation
import sdk
import SwiftUI
import voiceIDComponent

final class MainViewModel: NSObject, ObservableObject {
    @Published private(set) var logs = ""
    @Published private(set) var newOperationClicked = false
    @Published var enrollResult: UIComponentResult = .pending
    @Published var authResult: UIComponentResult = .pending

    // Media (AppMediaPlayer)
    @Published private(set) var audios: [URL] = []
    @Published private(set) var isPlaying = false
    @Published private(set) var audioIndex = 0
    private var audioPlayer: AVAudioPlayer?
    private var playingIndex = 0

    let version = sdk.Constants.libraryPackageVersion

    private var initialized = false

    private var enrollPhrases: [String] {
        ["onboarding_phrase_1".localized, "onboarding_phrase_2".localized, "onboarding_phrase_2".localized]
    }

    private var authPhrases: [String] {
        ["onboarding_phrase_1".localized]
    }

    func initSdk() {
        guard !initialized else { return }
        initialized = true

        SDKManager.shared.initSdk { [weak self] message in
            self?.log(message)
        }
    }

    func newOperation() {
        SDKManager.shared.newOperation(
            operationType: SdkConfigurationManager.OPERATION_TYPE,
            customerId: SdkConfigurationManager.CUSTOMER_ID
        ) { [weak self] result in
            if result.errorType == .NO_ERROR {
                self?.log("NEW OPERATION: OK")
                self?.onMain { self?.newOperationClicked = true }
            } else {
                self?.log("NEW OPERATION: Error - \(result.errorType)")
            }
        }
    }

    func launchVoiceEnroll(options: VoiceLaunchOptions) {
        guard let viewController = UIApplication.topViewController else { return }
        audios = []

        SDKManager.shared.launchVoice(
            viewController: viewController,
            voiceConfigurationData: configuration(phrases: enrollPhrases, options: options)
        ) { [weak self] result in
            guard let self else { return }
            if result.errorType == .NO_ERROR {
                self.log("Voice Enroll: OK")
                if let data = result.data?.audios, !data.isEmpty {
                    let files = self.saveAudios(data)
                    self.onMain {
                        self.audios = files
                        self.enrollResult = .ok
                    }
                }
            } else {
                self.log("Voice Enroll: Error - \(result.errorType)")
                self.onMain { self.enrollResult = .error }
            }
        }
    }

    func launchVoiceAuth(options: VoiceLaunchOptions) {
        guard let viewController = UIApplication.topViewController else { return }

        SDKManager.shared.launchVoice(
            viewController: viewController,
            voiceConfigurationData: configuration(phrases: authPhrases, options: options)
        ) { [weak self] result in
            guard let self else { return }
            if result.errorType == .NO_ERROR {
                self.log("Voice Auth: OK")
                self.onMain { self.authResult = .ok }
            } else {
                self.log("Voice Auth: Error - \(result.errorType)")
                self.onMain { self.authResult = .error }
            }
        }
    }

    func clearLogs() {
        logs = ""
        enrollResult = .pending
        authResult = .pending
    }

    // MARK: - Media

    func playAudios() {
        guard !audios.isEmpty else {
            print("APP - Voice result is empty")
            return
        }
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        playingIndex = 0
        audioIndex = 1
        isPlaying = true
        playNext()
    }

    func stopAudios() {
        print("APP - MEDIA STOP")
        audioPlayer?.stop()
        audioPlayer = nil
        playingIndex = 0
        isPlaying = false
    }

    private func playNext() {
        guard playingIndex < audios.count else {
            stopAudios()
            return
        }
        let file = audios[playingIndex]
        print("APP - MEDIA PLAY file:\(file.path)")
        do {
            let player = try AVAudioPlayer(contentsOf: file)
            player.delegate = self
            audioPlayer = player
            audioIndex = playingIndex + 1
            player.play()
        } catch {
            print("APP - MEDIA ERROR: \(error)")
            playingIndex += 1
            playNext()
        }
    }

    // MARK: - Helpers

    private func configuration(phrases: [String], options: VoiceLaunchOptions) -> VoiceConfigurationData {
        SdkConfigurationManager.voiceIDConfiguration(
            phrases: phrases,
            showPreviousTip: options.showPreviousTip,
            showTutorial: options.showTutorial,
            showDiagnostic: options.showDiagnostic,
            maxAttempts: options.maxAttempts
        )
    }

    /// Equivalent of Android AudioFileManager.saveWavToInternalStorage.
    private func saveAudios(_ data: [Data]) -> [URL] {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("audios")
        try? FileManager.default.removeItem(at: directory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        return data.enumerated().compactMap { index, audio in
            let file = directory.appendingPathComponent("audio\(index).wav")
            do {
                try audio.write(to: file)
                return file
            } catch {
                print("APP - AUDIO SAVING ERROR: \(file.path)")
                return nil
            }
        }
    }

    private func log(_ message: String) {
        print("APP - \(message)")
        onMain { self.logs += "\n" + message }
    }

    private func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }
}

extension MainViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onMain {
            guard self.isPlaying, player === self.audioPlayer else { return }
            self.playingIndex += 1
            self.playNext()
        }
    }
}

extension UIApplication {
    /// Top-most presented view controller, used to present the SDK components.
    static var topViewController: UIViewController? {
        let window = shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
