//
//  NfcScreenContent.swift
//  demosdk
//
//  Common body of Android ui/screens/MainScreen.kt and DataScreen.kt (DemoNFC):
//  version, PersonalInfoCard, Clear logs, NFC images and tappable logs (copy + e-mail).
//

import SwiftUI

final class LogStore: ObservableObject {
    @Published private(set) var lines: [String] = []

    var text: String { lines.joined(separator: "\n") }

    func add(_ line: String) { lines.append(line) }
    func clear() { lines.removeAll() }
}

struct NfcScreenFooter: View {
    @ObservedObject var viewModel: MainViewModel
    @ObservedObject var logs: LogStore
    let onClearLogs: () -> Void
    let onSendEmail: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 8)

            Text(viewModel.version)
                .font(.system(size: 16))
                .foregroundColor(.sdkBodyText)
                .frame(maxWidth: .infinity)

            Spacer().frame(height: 16)

            if let personalData = viewModel.personalData {
                PersonalInfoCard(info: personalData)
            }

            if !logs.lines.isEmpty {
                Rectangle()
                    .fill(Color(.lightGray))
                    .frame(height: 1)
                BaseTextButton(text: "Clear logs", action: onClearLogs)
            }

            if let face = viewModel.faceImage {
                Image(uiImage: face)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: face.size.width)
            }

            if let signature = viewModel.signatureImage {
                Image(uiImage: signature)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: signature.size.width)
            }

            Text(logs.text)
                .font(.system(size: 16))
                .foregroundColor(.sdkBodyText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
                .onTapGesture {
                    UIPasteboard.general.string = logs.text
                    onSendEmail(logs.text)
                }
        }
    }
}
