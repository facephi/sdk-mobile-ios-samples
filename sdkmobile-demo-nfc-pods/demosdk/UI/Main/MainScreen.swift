//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android ui/screens/MainScreen.kt (DemoNFC): "Capture with SelphID" tab.
//

import SwiftUI

struct MainScreen: View {
    @ObservedObject var viewModel: MainViewModel
    let onSendEmail: (String) -> Void

    @StateObject private var logs = LogStore()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ButtonCard(
                    title: "onboarding_title_operation".localized,
                    desc: "onboarding_desc_operation".localized,
                    buttonText: "onboarding_init_operation".localized
                ) {
                    print("APP - LAUNCH NEW OPERATION")
                    logs.clear()
                    viewModel.clearData()
                    viewModel.newOperation { logs.add($0) }
                }

                Spacer().frame(height: 8)

                SelphIDNfcComponentCard(
                    enabled: true,
                    title: "SELPHID + NFC",
                    result: viewModel.nfcResult
                ) { options, documentType, skipPACE in
                    viewModel.clearData()
                    viewModel.launchSelphidAndNfc(
                        skipPACE: skipPACE,
                        docType: documentType,
                        extractFace: options.extractFace,
                        extractSignature: options.extractSignature,
                        showPreviousTip: options.showPreviousTip,
                        showTutorial: options.showTutorial,
                        showDiagnostic: options.showDiagnostic,
                        readingProgressStyle: options.readingProgressStyle,
                        maxAttempts: options.maxAttempts
                    ) { logs.add($0) }
                }

                NfcScreenFooter(
                    viewModel: viewModel,
                    logs: logs,
                    onClearLogs: {
                        logs.clear()
                        viewModel.clearData()
                    },
                    onSendEmail: onSendEmail
                )
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
