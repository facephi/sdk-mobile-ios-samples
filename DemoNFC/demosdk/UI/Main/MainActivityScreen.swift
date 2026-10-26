//
//  MainActivityScreen.swift
//  demosdk
//
//  SwiftUI port of Android MainActivity.kt + ui/UIState.kt (DemoNFC):
//  Loading -> initSdk + newOperation -> Terms and conditions (GDPR) -> tabs.
//

import SwiftUI

enum UIState {
    case INITIAL, ERROR, DISCLAIMER, NFC_CAPTURE
}

struct MainActivityScreen: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var state: UIState = .INITIAL
    @State private var error = ""
    @State private var initialized = false
    @State private var disclaimerLaunched = false

    var body: some View {
        ZStack {
            Color.sdkBackground.ignoresSafeArea()

            switch state {
            case .INITIAL:
                LoadingRow()
                    .padding(16)
            case .ERROR:
                ErrorRow(message: error)
                    .padding(16)
            case .DISCLAIMER:
                Color.clear
                    .onAppear(perform: launchDisclaimer)
            case .NFC_CAPTURE:
                VStack(spacing: 0) {
                    // Scaffold topBar
                    Spacer().frame(height: 48)
                    DemoLogo()
                        .frame(maxWidth: .infinity)
                    TabScreen(viewModel: viewModel, onSendEmail: sendEmail)
                }
                .foregroundColor(.sdkBodyText)
            }
        }
        .onAppear {
            guard !initialized else { return }
            initialized = true
            print("APP - LAUNCH INIT SDK")
            viewModel.initSdk { data in
                if let data, !data.isEmpty {
                    state = .ERROR
                    error = data
                } else {
                    state = .DISCLAIMER
                }
            }
        }
    }

    private func launchDisclaimer() {
        guard !disclaimerLaunched else { return }
        disclaimerLaunched = true
        viewModel.launchTermsAndConditions(text: "nfc_gdpr_text".localized) { accepted in
            if accepted {
                state = .NFC_CAPTURE
            } else {
                state = .ERROR
                error = "Terms and Conditions not accepted"
            }
        }
    }

    private func sendEmail(_ message: String) {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = "sdkmobile@facephi.com"
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Prueba NFC Samples iOS (\(viewModel.formatEpochMillis()))"),
            URLQueryItem(name: "body", value: message),
        ]
        guard let url = components.url else { return }
        UIApplication.shared.open(url) { success in
            if !success { print("APP - EMAIL ERROR") }
        }
    }
}
