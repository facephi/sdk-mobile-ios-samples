//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoSelphIDClassic).
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                DemoLogo()

                ButtonCard(
                    title: "onboarding_title_operation".localized,
                    desc: "onboarding_desc_operation".localized,
                    buttonText: "onboarding_init_operation".localized
                ) {
                    viewModel.newOperation()
                }

                Spacer().frame(height: 8)

                SelphIDComponentCard(
                    enabled: viewModel.newOperationClicked,
                    title: "onboarding_title_selphid".localized,
                    desc: "onboarding_desc_selphid".localized,
                    buttonText: "onboarding_launch_selphid".localized,
                    result: viewModel.selphIdResult
                ) { options in
                    viewModel.launchSelphId(options: options)
                }

                Spacer().frame(height: 16)

                DemoFooter(
                    version: viewModel.version,
                    logs: viewModel.logs,
                    images: viewModel.images,
                    onClearLogs: viewModel.clearLogs
                )
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.sdkBackground.ignoresSafeArea())
        .onAppear { viewModel.initSdk() }
    }
}
