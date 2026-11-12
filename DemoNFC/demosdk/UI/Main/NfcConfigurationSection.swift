//
//  NfcConfigurationSection.swift
//  demosdk
//
//  Advanced configuration shared by Android SelphIDNfcComponentCard.kt and NfcComponentCard.kt (DemoNFC).
//

import nfcComponent
import SwiftUI

struct NfcLaunchOptions {
    var showPreviousTip = true
    var showTutorial = true
    var showDiagnostic = true
    var extractFace = true
    var extractSignature = true
    var readingProgressStyle: ReadingProgressStyle = .DOTS
    var maxAttempts = 3
}

private let maxAttemptsOptions = [1, 3, 5, 0]

struct NfcConfigurationSection: View {
    let enabled: Bool
    @Binding var options: NfcLaunchOptions
    @Binding var expanded: Bool

    var body: some View {
        AdvancedConfigurationSection(expanded: $expanded) {
            HStack(spacing: 8) {
                BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                BaseCheckView(text: "onboarding_show_tutorial".localized, isOn: $options.showTutorial)
            }
            .opacity(enabled ? 1 : 0.6)

            HStack(spacing: 8) {
                BaseCheckView(text: "nfc_extract_face".localized, isOn: $options.extractFace)
                BaseCheckView(text: "nfc_extract_signature".localized, isOn: $options.extractSignature)
            }
            .opacity(enabled ? 1 : 0.6)

            HStack(spacing: 8) {
                BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
                DropdownReadingProgress(selected: $options.readingProgressStyle)
            }
            .opacity(enabled ? 1 : 0.6)

            OptionLabel(text: "Max attempts (0 = unlimited)")
            ChipSelector(options: maxAttemptsOptions, selection: $options.maxAttempts, enabled: enabled) {
                $0 == 0 ? "Unlimited" : String($0)
            }
        }
    }
}
