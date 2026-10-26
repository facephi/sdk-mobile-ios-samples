//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoSelphiClassic).
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

                BaseComponentCard(
                    enabled: viewModel.newOperationClicked,
                    title: "onboarding_title_selphi".localized,
                    desc: "onboarding_desc_selphi".localized,
                    buttonText: "onboarding_launch_selphi".localized,
                    result: viewModel.selphiResult
                ) { options in
                    viewModel.launchSelphi(options: options)
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
        .background(Color.sdkBackground.ignoresSafeArea())
        .onAppear { viewModel.initSdk() }
    }
}
