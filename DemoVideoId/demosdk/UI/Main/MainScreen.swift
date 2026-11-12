//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoVideoId).
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

                VideoIdComponentCard(
                    enabled: viewModel.newOperationClicked,
                    title: "onboarding_title_video".localized,
                    desc: "onboarding_desc_video".localized,
                    buttonText: "onboarding_launch_video".localized,
                    result: viewModel.videoResult
                ) { autoFace in
                    viewModel.launchVideoId(autoFace: autoFace)
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
