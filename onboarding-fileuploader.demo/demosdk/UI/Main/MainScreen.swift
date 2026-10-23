//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoOnboardingFileUploader).
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

                // Video Recording
                StartAndStopCard(
                    title: "onboarding_title_videorecording".localized,
                    desc: "onboarding_desc_videorecording".localized,
                    startButtonText: "onboarding_launch_videorecording".localized,
                    stopButtonText: "onboarding_launch_stop_videorecording".localized,
                    result: viewModel.videoResult,
                    enabled: viewModel.newOperationClicked,
                    onStart: viewModel.launchVideoRecording,
                    onStop: viewModel.launchStopVideoRecording
                )

                Spacer().frame(height: 8)

                SelphiComponentCard(
                    enabled: viewModel.newOperationClicked,
                    title: "onboarding_title_selphi".localized,
                    desc: "onboarding_desc_selphi".localized,
                    buttonText: "onboarding_launch_selphi".localized,
                    result: viewModel.selphiResult
                ) { options in
                    viewModel.launchSelphi(options: options)
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

                Spacer().frame(height: 8)

                FileUploaderCard(
                    enabled: viewModel.newOperationClicked,
                    title: "onboarding_title_file_uploader".localized,
                    desc: "onboarding_desc_file_uploader".localized,
                    buttonText: "onboarding_launch_file_uploader".localized,
                    result: viewModel.uploaderResult
                ) { options in
                    viewModel.launchFileUploader(options: options)
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
