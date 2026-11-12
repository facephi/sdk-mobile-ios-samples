//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoVoice).
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

                VoiceComponentCard(
                    enabled: viewModel.newOperationClicked,
                    title: "onboarding_title_voice".localized,
                    desc: "onboarding_desc_voice".localized,
                    resultFirst: viewModel.enrollResult,
                    resultSecond: viewModel.authResult,
                    onLaunchFirst: viewModel.launchVoiceEnroll,
                    onLaunchSecond: viewModel.launchVoiceAuth
                )

                Spacer().frame(height: 8)

                MediaCard(
                    title: "onboarding_title_media".localized,
                    desc: "onboarding_desc_media".localized,
                    playText: "onboarding_play".localized,
                    enabled: viewModel.newOperationClicked && !viewModel.audios.isEmpty,
                    isPlaying: viewModel.isPlaying,
                    audioIndex: viewModel.audioIndex,
                    onPlay: viewModel.playAudios,
                    onStop: viewModel.stopAudios
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
