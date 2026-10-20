//
//  DemoPhingersKmpCustomViews.swift
//  demosdk
//
//  Demo-only Phingers custom camera overlay (✋) via SDK component passthrough.
//

import FPHIPhingersWidget
import phingersTFComponent
import SwiftUI
import UIKit

extension DemoKmpCustomViewsFactory {
    static func makePhingersCustomViewsWithOverlay() -> PhingersCustomViews {
        PhingersCustomViews(
            previousTipView: PhingersIOSPreviousTipViewAdapter(factory: DemoPhingersKmpCustomPreviousTipViewFactory()),
            tutorialView: PhingersIOSTutorialViewAdapter(factory: DemoPhingersKmpCustomTutorialViewFactory()),
            fingerSelectorView: nil,
            cameraView: PhingersIOSCameraViewAdapter(factory: DemoPhingersKmpCustomCameraViewFactory()),
            errorDiagnosticView: nil
        )
    }
}

private final class DemoPhingersKmpCustomPreviousTipViewFactory: PhingersIOSPreviousTipViewFactory {
    func makeView(
        fingerFilter: FPHIPhingersWidget.FingerFilter,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onInfo: @escaping () -> Void
    ) -> UIView {
        DemoKmpCustomHosting.makeView {
            DemoKmpFlowScreen(
                emoji: "✋",
                title: "PHINGERS · PREVIOUS TIP",
                subtitle: fingerFilter.name,
                onClose: onCancel
            ) {
                Button("Tutorial", action: onInfo)
                Button("Continue", action: onContinue)
            }
        }
    }
}

private final class DemoPhingersKmpCustomTutorialViewFactory: PhingersIOSTutorialViewFactory {
    func makeView(
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void,
        onSkip: @escaping () -> Void
    ) -> UIView {
        DemoKmpCustomHosting.makeView {
            DemoKmpFlowScreen(emoji: "✋", title: "PHINGERS · TUTORIAL", subtitle: "Demo custom view", onClose: onCancel) {
                Button("Continue", action: onContinue)
                Button("Skip", action: onSkip)
            }
        }
    }
}


private final class DemoPhingersKmpCustomCameraViewFactory: PhingersIOSCameraViewFactory {
    func makeView(
        statusMessage: String?,
        flashEnabled: Bool,
        onFlashToggle: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) -> UIView {
        let state = DemoPhingersCameraOverlayState(statusMessage: statusMessage, flashEnabled: flashEnabled)
        let hostingController = UIHostingController(
            rootView: DemoPhingersCameraOverlayScreen(
                state: state,
                onFlashToggle: onFlashToggle,
                onCancel: onCancel
            )
        )
        hostingController.view.backgroundColor = .clear
        return DemoPhingersCameraOverlayHostView(state: state, hostedView: hostingController.view)
    }

    func updateView(view: UIView, statusMessage: String?, flashEnabled: Bool) {
        (view as? DemoPhingersCameraOverlayHostView)?.update(statusMessage: statusMessage, flashEnabled: flashEnabled)
    }
}

private final class DemoPhingersCameraOverlayState: ObservableObject {
    @Published var statusMessage: String?
    @Published var flashEnabled: Bool

    init(statusMessage: String?, flashEnabled: Bool) {
        self.statusMessage = statusMessage
        self.flashEnabled = flashEnabled
    }

    func update(statusMessage: String?, flashEnabled: Bool) {
        self.statusMessage = statusMessage
        self.flashEnabled = flashEnabled
    }
}

private final class DemoPhingersCameraOverlayHostView: UIView {
    private let state: DemoPhingersCameraOverlayState

    init(state: DemoPhingersCameraOverlayState, hostedView: UIView) {
        self.state = state
        super.init(frame: .zero)
        addSubview(hostedView)
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostedView.topAnchor.constraint(equalTo: topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            hostedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(statusMessage: String?, flashEnabled: Bool) {
        state.update(statusMessage: statusMessage, flashEnabled: flashEnabled)
    }
}

private struct DemoPhingersCameraOverlayScreen: View {
    @ObservedObject var state: DemoPhingersCameraOverlayState
    let onFlashToggle: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
            VStack {
                DemoComponentBadge(emoji: "✋", title: "PHINGERS")
                    .padding(.top, 8)
                HStack {
                    Spacer()
                    Button(state.flashEnabled ? "Flash ON" : "Flash OFF", action: onFlashToggle)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                    Button("X", action: onCancel)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                }
                .padding(.horizontal)
                Spacer()
                if let statusMessage = state.statusMessage, !statusMessage.isEmpty {
                    Text(statusMessage)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                }
            }
        }
    }
}
