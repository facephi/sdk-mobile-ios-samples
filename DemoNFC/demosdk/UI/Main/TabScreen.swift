//
//  TabScreen.swift
//  demosdk
//
//  SwiftUI port of Android ui/screens/TabScreen.kt (DemoNFC).
//

import SwiftUI

struct TabScreen: View {
    @ObservedObject var viewModel: MainViewModel
    let onSendEmail: (String) -> Void

    @State private var tabIndex = 0

    private var tabs: [String] {
        ["nfc_read_with_capture".localized, "nfc_read_with_data".localized]
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, title in
                    Button {
                        tabIndex = index
                    } label: {
                        VStack(spacing: 0) {
                            Spacer(minLength: 0)
                            Text(title)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.nfcPrimary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                            Spacer(minLength: 0)
                            Rectangle()
                                .fill(tabIndex == index ? Color.nfcPrimary : Color.clear)
                                .frame(height: 3)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(Color.nfcPrimary.opacity(0.12))

            switch tabIndex {
            case 0: MainScreen(viewModel: viewModel, onSendEmail: onSendEmail)
            default: DataScreen(viewModel: viewModel, onSendEmail: onSendEmail)
            }
        }
    }
}
