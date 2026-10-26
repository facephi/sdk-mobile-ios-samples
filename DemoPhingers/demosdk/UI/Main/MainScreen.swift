//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoPhingers).
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                DemoLogo(padding: 16)

                ButtonCard(
                    title: "onboarding_title_operation".localized,
                    desc: "onboarding_desc_operation".localized,
                    buttonText: "onboarding_init_operation".localized
                ) {
                    viewModel.newOperation()
                }

                Spacer().frame(height: 8)

                PhingersComponentCard(
                    enabled: viewModel.newOperationClicked,
                    title: "onboarding_title_phinger".localized,
                    desc: "onboarding_desc_phinger".localized,
                    buttonText: "onboarding_launch_phinger".localized,
                    result: viewModel.phingersResult
                ) { options in
                    viewModel.launchPhingers(options: options)
                }

                Spacer().frame(height: 16)

                DemoFooter(
                    version: viewModel.version,
                    logs: viewModel.logs,
                    images: [],
                    onClearLogs: viewModel.clearLogs
                )
            }
            .padding(16)
        }
        .background(Color.sdkBackground.ignoresSafeArea())
        .onAppear { viewModel.initSdk() }
    }
}
