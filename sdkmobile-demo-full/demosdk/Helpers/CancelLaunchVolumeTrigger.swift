//
//  CancelLaunchVolumeTrigger.swift
//  demosdk
//

import AVFoundation
import MediaPlayer
import UIKit

/// Demo-only helper that triggers `cancelLaunch` when the user presses volume up
/// or triple-taps the middle-right edge of the screen.
///
/// The listener is paused automatically while the app is inactive (for example, during a
/// system permission dialog) so gestures do not cancel a component unexpectedly.
///
/// Detection layers (demo-only):
/// 1. KVO on `AVAudioSession.outputVolume` (public API).
/// 2. Private `AVSystemController_SystemVolumeDidChangeNotification` (QuickTime fallback attempt).
/// 3. Triple-tap on the middle-right screen area (reliable fallback for QuickTime mirroring).
final class CancelLaunchVolumeTrigger {
    static let shared = CancelLaunchVolumeTrigger()

    private static let baselineVolume: Float = 0.5
    private static let triggerDebounceInterval: TimeInterval = 0.35
    /// Diagnostic only: after the app resigns active (NFC system sheet, permission dialog),
    /// call `cancelLaunch` even though the volume listener is paused.
    /// Set to `nil` to disable. Remove once the NFC sheet cancel path is confirmed.
    private static let inactiveCancelDiagnosticDelay: TimeInterval? = 4

    private var isUserEnabled = false
    private var isListening = false
    private var volumeObservation: NSKeyValueObservation?
    private var hiddenVolumeView: MPVolumeView?
    private var onLog: ((String) -> Void)?
    private var onCancelLaunch: (() -> Void)?
    private var lastObservedVolume: Float = baselineVolume
    private var lastTriggerDate: Date?
    private var inactiveCancelDiagnostic: DispatchWorkItem?

    private init() {}

    func enable(onLog: @escaping (String) -> Void, onCancelLaunch: @escaping () -> Void) {
        self.onLog = onLog
        self.onCancelLaunch = onCancelLaunch

        guard !isUserEnabled else {
            onLog("Cancel listener: already enabled")
            return
        }

        isUserEnabled = true
        onLog("Cancel listener: ENABLED (volume up + triple-tap middle-right)")

        installHiddenVolumeViewIfNeeded()

        if UIApplication.shared.applicationState == .active {
            startListening(logResume: false)
        } else {
            onLog("Cancel listener: armed, waiting for app to become active")
        }
    }

    func disable(onLog: @escaping (String) -> Void) {
        guard isUserEnabled else {
            onLog("Cancel listener: already disabled")
            return
        }

        isUserEnabled = false
        cancelInactiveCancelDiagnostic()
        stopListening()
        onLog("Cancel listener: DISABLED")
    }

    func applicationDidBecomeActive() {
        cancelInactiveCancelDiagnostic()
        guard isUserEnabled else { return }
        startListening(logResume: true)
    }

    func applicationWillResignActive() {
        guard isUserEnabled, isListening else { return }
        stopListening()
        onLog?("Cancel listener: paused while app is inactive (e.g. permission dialog)")
        scheduleInactiveCancelDiagnostic()
    }

    private func startListening(logResume: Bool) {
        guard !isListening else { return }

        configureAudioSessionForVolumeCapture()

        lastObservedVolume = Self.baselineVolume
        resetSystemVolume(to: Self.baselineVolume)

        let session = AVAudioSession.sharedInstance()
        volumeObservation = session.observe(\.outputVolume, options: [.old, .new]) { [weak self] _, change in
            self?.handleVolumeChange(
                source: "KVO",
                oldValue: change.oldValue,
                newValue: change.newValue
            )
        }

        SystemVolumePrivateObserver.shared.start { [weak self] oldValue, newValue in
            self?.handleVolumeChange(
                source: "private API",
                oldValue: oldValue,
                newValue: newValue
            )
        }

        CancelLaunchTripleTapOverlay.shared.show { [weak self] in
            self?.triggerCancel(source: "triple-tap middle-right")
        }

        isListening = true

        if logResume {
            onLog?("Cancel listener: resumed (app active)")
        } else {
            onLog?("Cancel listener: listening (volume + triple-tap middle-right)")
        }
    }

    private func stopListening() {
        volumeObservation?.invalidate()
        volumeObservation = nil
        SystemVolumePrivateObserver.shared.stop()
        CancelLaunchTripleTapOverlay.shared.hide()
        isListening = false
    }

    /// Configures audio session so hardware volume stays routed to the device when possible
    /// (e.g. QuickTime screen mirroring may otherwise swallow volume key events).
    private func configureAudioSessionForVolumeCapture() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(
                .playAndRecord,
                mode: .default,
                options: [.defaultToSpeaker, .mixWithOthers]
            )
            try session.setActive(true)
            onLog?("Cancel listener: audio session configured (playAndRecord)")
        } catch {
            onLog?("Cancel listener: failed to configure audio session (\(error.localizedDescription))")
        }
    }

    private func handleVolumeChange(source: String, oldValue: Float?, newValue: Float?) {
        guard isUserEnabled, isListening else { return }
        guard UIApplication.shared.applicationState == .active else { return }

        let previousVolume = oldValue ?? lastObservedVolume
        let currentVolume = newValue ?? previousVolume
        lastObservedVolume = currentVolume

        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.resetSystemVolume(to: Self.baselineVolume)
                self?.lastObservedVolume = Self.baselineVolume
            }
        }

        let isVolumeUpPress: Bool
        switch source {
        case "KVO":
            // Volume-up press: level rises briefly; MPVolumeView reset appears as a decrease in KVO.
            isVolumeUpPress = currentVolume < previousVolume
        case "private API":
            isVolumeUpPress = currentVolume > previousVolume
        default:
            return
        }

        guard isVolumeUpPress else { return }
        triggerCancel(source: source)
    }

    private func scheduleInactiveCancelDiagnostic() {
        guard let delay = Self.inactiveCancelDiagnosticDelay else { return }

        cancelInactiveCancelDiagnostic()
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.isUserEnabled else { return }
            guard UIApplication.shared.applicationState != .active else { return }

            self.onLog?("Cancel listener: diagnostic timer firing cancelLaunch while app is inactive")
            self.onCancelLaunch?()
        }
        inactiveCancelDiagnostic = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
        onLog?("Cancel listener: diagnostic timer armed (\(delay)s) while app is inactive")
    }

    private func cancelInactiveCancelDiagnostic() {
        inactiveCancelDiagnostic?.cancel()
        inactiveCancelDiagnostic = nil
    }

    private func triggerCancel(source: String) {
        guard isUserEnabled, isListening else { return }
        guard UIApplication.shared.applicationState == .active else { return }
        guard shouldEmitTrigger() else { return }

        onLog?("Cancel listener: triggered cancelLaunch via \(source)")
        onCancelLaunch?()
    }

    private func shouldEmitTrigger() -> Bool {
        let now = Date()
        defer { lastTriggerDate = now }

        guard let lastTriggerDate else { return true }
        return now.timeIntervalSince(lastTriggerDate) >= Self.triggerDebounceInterval
    }

    private func installHiddenVolumeViewIfNeeded() {
        guard hiddenVolumeView == nil else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self, self.hiddenVolumeView == nil else { return }

            let volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
            volumeView.alpha = 0.01
            volumeView.showsRouteButton = false

            guard let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .flatMap(\.windows)
                .first(where: \.isKeyWindow) else {
                self.onLog?("Cancel listener: could not attach hidden volume view")
                return
            }

            window.addSubview(volumeView)
            self.hiddenVolumeView = volumeView
            self.resetSystemVolume(to: Self.baselineVolume)
        }
    }

    private func resetSystemVolume(to value: Float) {
        guard let slider = hiddenVolumeView?.subviews.compactMap({ $0 as? UISlider }).first else { return }
        slider.value = value
    }
}

// MARK: - Triple-tap middle-right overlay (demo-only)

/// Transparent overlay window that only captures triple-taps in the middle-right region.
/// Stays above SDK component screens (QuickTime-friendly cancel fallback).
private final class CancelLaunchTripleTapOverlay {
    static let shared = CancelLaunchTripleTapOverlay()

    private var overlayWindow: PassthroughOverlayWindow?
    private var onTripleTap: (() -> Void)?

    private init() {}

    func show(onTripleTap: @escaping () -> Void) {
        self.onTripleTap = onTripleTap

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            if let overlayWindow = self.overlayWindow {
                overlayWindow.isHidden = false
                overlayWindow.layoutTapZone()
                return
            }

            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive }) else {
                return
            }

            let window = PassthroughOverlayWindow(windowScene: scene)
            window.windowLevel = .alert + 1
            window.backgroundColor = .clear
            window.onTripleTap = { [weak self] in
                self?.onTripleTap?()
            }
            window.layoutTapZone()
            window.isHidden = false
            self.overlayWindow = window
        }
    }

    func hide() {
        DispatchQueue.main.async { [weak self] in
            self?.overlayWindow?.isHidden = true
        }
    }
}

private final class PassthroughOverlayWindow: UIWindow {
    var onTripleTap: (() -> Void)?

    private let tapZone = UIView()
    private var tapZoneWidthConstraint: NSLayoutConstraint?
    private var tapZoneHeightConstraint: NSLayoutConstraint?

    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        configureTapZone()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func layoutTapZone() {
        guard let screenBounds = windowScene?.screen.bounds else { return }

        let zoneWidth = min(80, screenBounds.width * 0.18)
        let zoneHeight = min(180, screenBounds.height * 0.28)

        tapZoneWidthConstraint?.constant = zoneWidth
        tapZoneHeightConstraint?.constant = zoneHeight
        layoutIfNeeded()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !isHidden, alpha > 0, isUserInteractionEnabled else { return nil }
        let pointInTapZone = convert(point, to: tapZone)
        return tapZone.bounds.contains(pointInTapZone) ? tapZone : nil
    }

    private func configureTapZone() {
        tapZone.backgroundColor = .clear
        tapZone.isAccessibilityElement = true
        tapZone.accessibilityLabel = "Cancel launch triple-tap zone"
        tapZone.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tapZone)

        let widthConstraint = tapZone.widthAnchor.constraint(equalToConstant: 80)
        let heightConstraint = tapZone.heightAnchor.constraint(equalToConstant: 180)
        tapZoneWidthConstraint = widthConstraint
        tapZoneHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            tapZone.trailingAnchor.constraint(equalTo: trailingAnchor),
            tapZone.centerYAnchor.constraint(equalTo: centerYAnchor),
            widthConstraint,
            heightConstraint
        ])

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTripleTap))
        recognizer.numberOfTapsRequired = 3
        recognizer.numberOfTouchesRequired = 1
        tapZone.addGestureRecognizer(recognizer)
    }

    @objc private func handleTripleTap() {
        onTripleTap?()
    }
}

// MARK: - Private system volume notification (demo-only fallback)

/// Observes the undocumented system volume notification.
/// Used only in the demo app — not for App Store SDK distribution.
private final class SystemVolumePrivateObserver {
    static let shared = SystemVolumePrivateObserver()

    private enum Keys {
        static let notification = Notification.Name("AVSystemController_SystemVolumeDidChangeNotification")
        static let volume = "AVSystemController_AudioVolumeNotificationParameter"
        static let reason = "AVSystemController_AudioVolumeChangeReasonNotificationParameter"
        static let explicitHardwareChange = "ExplicitVolumeChange"
    }

    private var token: NSObjectProtocol?
    private var lastVolume: Float?
    private var handler: ((Float?, Float?) -> Void)?

    private init() {}

    func start(handler: @escaping (Float?, Float?) -> Void) {
        stop()
        self.handler = handler
        lastVolume = AVAudioSession.sharedInstance().outputVolume

        token = NotificationCenter.default.addObserver(
            forName: Keys.notification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handle(notification)
        }
    }

    func stop() {
        if let token {
            NotificationCenter.default.removeObserver(token)
        }
        token = nil
        handler = nil
        lastVolume = nil
    }

    private func handle(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }

        if let reason = userInfo[Keys.reason] as? String,
           reason != Keys.explicitHardwareChange {
            return
        }

        let newVolume: Float?
        if let number = userInfo[Keys.volume] as? NSNumber {
            newVolume = number.floatValue
        } else if let string = userInfo[Keys.volume] as? String, let value = Float(string) {
            newVolume = value
        } else {
            newVolume = AVAudioSession.sharedInstance().outputVolume
        }

        let previousVolume = lastVolume
        lastVolume = newVolume
        handler?(previousVolume, newVolume)
    }
}
