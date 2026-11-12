//
//  MainScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainScreen.kt (DemoIDV).
//

import sdk
import SwiftUI

struct MainScreen: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedFlow: IntegrationFlowData?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                DemoLogo()

                if !viewModel.flowList.isEmpty {
                    Spacer().frame(height: 8)
                    FlowSelector(
                        flows: viewModel.flowList,
                        selected: selectedFlow,
                        onSelected: { selectedFlow = $0 }
                    )
                    Spacer().frame(height: 8)
                }

                BaseButton(
                    text: "onboarding_launch_idv".localized,
                    enabled: viewModel.sdkReady,
                    loading: viewModel.flowActive
                ) {
                    viewModel.start(flowId: selectedFlow?.id)
                }
                .padding(.vertical, 8)

                Spacer().frame(height: 8)

                Text(viewModel.version)
                    .font(.system(size: 16))
                    .foregroundColor(.demoOnSurface)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)

                if !viewModel.logs.isEmpty {
                    Rectangle()
                        .fill(Color(.lightGray))
                        .frame(height: 1)
                    BaseTextButton(text: "Clear logs", action: viewModel.clearLogs)
                    Text(viewModel.logs)
                        .font(.system(size: 14))
                        .foregroundColor(.sdkBodyText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .textSelection(.enabled)
                }
            }
            .padding(16)
        }
        .background(Color.sdkBackground.ignoresSafeArea())
        .onAppear { viewModel.initSdk() }
        .onChange(of: viewModel.flowList.map(\.id)) { ids in
            // Same as Android: first flow is selected by default
            if selectedFlow == nil, let first = viewModel.flowList.first, ids.contains(first.id) {
                selectedFlow = first
            }
        }
    }
}
