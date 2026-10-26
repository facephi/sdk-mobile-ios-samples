//
//  VoiceComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/BaseComponentCard.kt (DemoVoice).
//

import SwiftUI

struct VoiceLaunchOptions {
    var showPreviousTip = true
    var showTutorial = true
    var showDiagnostic = true
    var maxAttempts = 3
}

private let maxAttemptsOptions = [1, 3, 5, 0]

struct VoiceComponentCard: View {
    let enabled: Bool
    let title: String
    let desc: String
    let resultFirst: UIComponentResult
    let resultSecond: UIComponentResult
    let onLaunchFirst: (VoiceLaunchOptions) -> Void
    let onLaunchSecond: (VoiceLaunchOptions) -> Void

    @State private var options = VoiceLaunchOptions()

    var body: some View {
        DemoCard(title: title, desc: desc) {
            HStack(spacing: 12) {
                BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                BaseCheckView(text: "onboarding_show_tutorial".localized, isOn: $options.showTutorial)
            }
            .opacity(enabled ? 1 : 0.6)

            HStack {
                BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 0)
            }
            .opacity(enabled ? 1 : 0.6)

            OptionLabel(text: "Max attempts (0 = unlimited)")
            ChipSelector(options: maxAttemptsOptions, selection: $options.maxAttempts, enabled: enabled) {
                $0 == 0 ? "Unlimited" : String($0)
            }

            BaseButton(text: "onboarding_launch_enroll".localized, enabled: enabled) {
                onLaunchFirst(options)
            }

            ResultRow(result: resultFirst)

            BaseButton(text: "onboarding_launch_auth".localized, enabled: enabled) {
                onLaunchSecond(options)
            }

            ResultRow(result: resultSecond)
        }
    }
}
