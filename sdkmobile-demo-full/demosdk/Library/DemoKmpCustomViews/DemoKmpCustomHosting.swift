//
//  DemoKmpCustomHosting.swift
//  demosdk
//

import SwiftUI
import UIKit

enum DemoKmpCustomHosting {
    static func makeView<Content: View>(@ViewBuilder content: () -> Content) -> UIView {
        let hostingController = UIHostingController(rootView: content())
        hostingController.view.backgroundColor = .systemBackground
        return hostingController.view
    }
}

struct DemoKmpFlowScreen<Actions: View>: View {
    let emoji: String
    let title: String
    var subtitle: String?
    let onClose: () -> Void
    @ViewBuilder let actions: () -> Actions

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                DemoComponentBadge(emoji: emoji, title: title)
                Spacer()
                Button("X", action: onClose)
                    .font(.headline)
            }
            .padding(.horizontal)
            .padding(.top, 8)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()

            VStack(spacing: 12) {
                actions()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
