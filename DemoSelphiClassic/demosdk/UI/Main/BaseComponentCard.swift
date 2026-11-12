//
//  BaseComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/BaseComponentCard.kt (DemoSelphiClassic).
//

import SwiftUI

struct SelphiLaunchOptions {
    var showPreviousTip = true
    var showTutorial = true
    var showDiagnostic = true
}

struct BaseComponentCard: View {
    let enabled: Bool
    let title: String
    let desc: String
    let buttonText: String
    let result: UIComponentResult
    let onLaunch: (SelphiLaunchOptions) -> Void

    @State private var options = SelphiLaunchOptions()
    @State private var expanded = false

    var body: some View {
        DemoCard(title: title, desc: desc) {
            AdvancedConfigurationSection(expanded: $expanded) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                        BaseCheckView(text: "onboarding_show_tutorial".localized, isOn: $options.showTutorial)
                    }
                    .opacity(enabled ? 1 : 0.6)

                    BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
                        .fixedSize(horizontal: true, vertical: false)
                        .opacity(enabled ? 1 : 0.6)
                }
            }

            BaseButton(text: buttonText, enabled: enabled) {
                onLaunch(options)
            }

            ResultRow(result: result)
        }
    }
}
