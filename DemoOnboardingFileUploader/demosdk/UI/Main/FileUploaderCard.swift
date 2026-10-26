//
//  FileUploaderCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/FileUploaderCard.kt.
//

import SwiftUI

struct FileUploaderLaunchOptions {
    var showPreviousTip = true
    var allowGallery = true
    var showDiagnostic = true
    var maxDocuments = 2
}

struct FileUploaderCard: View {
    let enabled: Bool
    let title: String
    let desc: String
    let buttonText: String
    let result: UIComponentResult
    let onLaunch: (FileUploaderLaunchOptions) -> Void

    @State private var options = FileUploaderLaunchOptions()
    @State private var expanded = false

    var body: some View {
        DemoCard(title: title, desc: desc) {
            AdvancedConfigurationSection(expanded: $expanded) {
                Group {
                    HStack(spacing: 12) {
                        BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                        BaseCheckView(text: "onboarding_allow_gallery".localized, isOn: $options.allowGallery)
                    }
                    BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
                        .fixedSize(horizontal: true, vertical: false)
                }
                .opacity(enabled ? 1 : 0.6)

                SettingStepperRow(text: "Documentos a capturar", value: $options.maxDocuments, range: 1...20)
            }

            BaseButton(text: buttonText, enabled: enabled) {
                onLaunch(options)
            }

            ResultRow(result: result)
        }
    }
}
