//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoVideoCall).
//

import SwiftUI

struct MainScreen: View {
    @StateObject private var viewModel = MainViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                DemoLogo()

                ButtonCard(
                    title: "demo_title_operation".localized,
                    desc: "demo_desc_operation".localized,
                    buttonText: "demo_init_operation".localized
                ) {
                    viewModel.newOperation()
                }

                Spacer().frame(height: 8)

                StartAndStopCard(
                    title: "demo_title_video".localized,
                    desc: "demo_desc_video".localized,
                    startButtonText: "demo_launch_video".localized,
                    stopButtonText: "demo_stop_video".localized,
                    result: viewModel.videoResult,
                    enabled: viewModel.newOperationClicked,
                    okLabel: "demo_result_ok".localized,
                    errorLabel: "demo_result_error".localized,
                    onStart: viewModel.launchVideoCall,
                    onStop: viewModel.stopScreenSharing
                )

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
