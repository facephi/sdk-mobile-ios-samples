//
//  DataScreen.swift
//  demosdk
//
//  SwiftUI port of Android ui/screens/DataScreen.kt (DemoNFC): "Capture with data" tab.
//

import SwiftUI

struct DataScreen: View {
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

                NfcComponentCard(
                    enabled: true,
                    title: "onboarding_title_nfc".localized,
                    result: viewModel.nfcResult
                ) { configuration in
                    viewModel.clearData()
                    logs.add("Reading NFC...")
                    viewModel.launchNfc(nfcConfigurationData: configuration) { logs.add($0) }
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
