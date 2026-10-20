//
//  DemoKmpCustomViews.swift
//  demosdk
//
//  Demo-only Selphi / Phingers custom camera overlays via SDK component passthrough.
//

import FPHISelphiWidget
import phingersTFComponent
import selphiComponent
import SwiftUI
import UIKit

enum DemoKmpCustomViewsFactory {
    static func makePhingersCustomViews() -> PhingersCustomViews {
        makePhingersCustomViewsWithOverlay()
    }

    static func makeSelphiCustomViews() -> SelphiCustomViews {
        let previousTip = SelphiIOSPreviousTipViewAdapter(factory: DemoSelphiKmpCustomPreviousTipViewFactory())
        let tutorial = SelphiIOSTutorialViewAdapter(factory: DemoSelphiKmpCustomTutorialViewFactory())
        return SelphiCustomViews(
            previousTip: previousTip,
            tutorial: tutorial,
            cameraView: SelphiIOSCameraViewAdapter(factory: DemoSelphiKmpCustomCameraViewFactory()),
            confirmationView: nil,
            qrPreviousTip: previousTip,
            qrTutorial: tutorial,
            qrCameraView: nil,
            errorDiagnostic: nil
        )
    }
}

// MARK: - Selphi previous tip & tutorial

private final class DemoSelphiKmpCustomPreviousTipViewFactory: SelphiIOSPreviousTipViewFactory {
    func makeView(onContinue: @escaping () -> Void, onClose: @escaping () -> Void, onInfo: @escaping () -> Void) -> UIView {
        DemoKmpCustomHosting.makeView {
            DemoKmpFlowScreen(emoji: "☀️", title: "SELPHI · PREVIOUS TIP", subtitle: "Demo custom view", onClose: onClose) {
                Button("Tutorial", action: onInfo)
                Button("Continue", action: onContinue)
            }
        }
    }
}

private final class DemoSelphiKmpCustomTutorialViewFactory: SelphiIOSTutorialViewFactory {
    func makeView(onClose: @escaping () -> Void) -> UIView {
        DemoKmpCustomHosting.makeView {
            DemoKmpFlowScreen(emoji: "☀️", title: "SELPHI · TUTORIAL", subtitle: "Demo custom view (close = widget flow)", onClose: onClose) {
                Button("Close", action: onClose)
            }
        }
    }
}


// MARK: - Selphi camera overlay (☀️)

private final class DemoSelphiKmpCustomCameraViewFactory: SelphiIOSCameraViewFactory {
    func makeView(
        cameraResources: MainCameraResourcesData,
        lastSecondsMessage: String?,
        durationMillis: Int32,
        onClose: @escaping () -> Void,
        onInfo: (() -> Void)?
    ) -> UIView {
        makeSelphiCameraOverlay(
            cameraResources: cameraResources,
            durationMillis: durationMillis,
            onClose: onClose,
            onInfo: onInfo
        )
    }

    func updateView(view: UIView, cameraResources: MainCameraResourcesData, durationMillis: Int32) {
        (view as? DemoSelphiCameraOverlayHostView)?.update(cameraResources: cameraResources)
    }
}

private final class DemoSelphiCameraOverlayState: ObservableObject {
    @Published var message: String
    @Published var progressState: ProgressState

    init(cameraResources: MainCameraResourcesData) {
        message = cameraResources.message
        progressState = cameraResources.progressState
    }

    func update(cameraResources: MainCameraResourcesData) {
        message = cameraResources.message
        progressState = cameraResources.progressState
    }
}

private final class DemoSelphiCameraOverlayHostView: UIView {
    private let state: DemoSelphiCameraOverlayState

    init(state: DemoSelphiCameraOverlayState, hostedView: UIView) {
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

    func update(cameraResources: MainCameraResourcesData) {
        state.update(cameraResources: cameraResources)
    }
}

private func makeSelphiCameraOverlay(
    cameraResources: MainCameraResourcesData,
    durationMillis: Int32,
    onClose: @escaping () -> Void,
    onInfo: (() -> Void)?
) -> UIView {
    let state = DemoSelphiCameraOverlayState(cameraResources: cameraResources)
    let hostingController = UIHostingController(
        rootView: DemoSelphiCameraOverlayScreen(
            state: state,
            durationMillis: durationMillis,
            onClose: onClose,
            onInfo: onInfo
        )
    )
    hostingController.view.backgroundColor = .clear
    return DemoSelphiCameraOverlayHostView(state: state, hostedView: hostingController.view)
}

private struct DemoSelphiCameraOverlayScreen: View {
    @ObservedObject var state: DemoSelphiCameraOverlayState
    let durationMillis: Int32
    let onClose: () -> Void
    let onInfo: (() -> Void)?

    var body: some View {
        GeometryReader { geometry in
            let dimension = min(geometry.size.width, geometry.size.height) * 0.8
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.7))
                    .overlay(
                        Circle()
                            .frame(width: dimension, height: dimension)
                            .position(center)
                            .blendMode(.destinationOut)
                    )
                    .compositingGroup()

                DemoSelphiProgressRing(progressState: state.progressState, durationMillis: durationMillis)
                    .frame(width: dimension, height: dimension)
                    .position(center)

                VStack {
                    DemoComponentBadge(emoji: "☀️", title: "SELPHI")
                        .padding(.top, 8)
                    HStack {
                        Spacer()
                        Button("Tutorial") { onInfo?() }
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                        Button("X", action: onClose)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                    }
                    .padding(.horizontal)
                    Spacer()
                }

                VStack {
                    Spacer()
                    Text(state.message)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 120)
                }
            }
        }
    }
}

private struct DemoSelphiProgressRing: View {
    let progressState: ProgressState
    let durationMillis: Int32
    @State private var progress: CGFloat = 0

    private var color: Color {
        if progressState === ProgressState.show { return .green }
        if progressState === ProgressState.error { return .red }
        return Color(white: 0.8)
    }

    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: 24, dash: [15, 10]))
            .rotationEffect(.degrees(-90))
            .onAppear { restart() }
            //.onChange(of: progressState) { _ in restart() }
    }

    private func restart() {
        if progressState === ProgressState.show {
            progress = 0
            withAnimation(.linear(duration: Double(durationMillis) / 1000)) {
                progress = 1
            }
        } else {
            progress = 1
        }
    }
}

// MARK: - Shared badge

struct DemoComponentBadge: View {
    let emoji: String
    let title: String

    var body: some View {
        HStack(spacing: 8) {
            Text(emoji)
                .font(.largeTitle)
            Text(title)
                .font(.headline.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.85))
        .clipShape(Capsule())
        .accessibilityElement(children: .combine)
        //.accessibilityLabel("\(title) demo custom view")
    }
}
