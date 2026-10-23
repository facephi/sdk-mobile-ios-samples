//
//  SelphIDComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/SelphIDComponentCard.kt (DemoSelphIDClassic).
//

import selphidClassicComponent
import SwiftUI

struct SelphIDLaunchOptions {
    var showPreviousTip = true
    var showTutorial = true
    var showDiagnostic = true
    var wizardMode = true
    var showResultAfterCapture = true
    var scanMode: SelphIDScanMode = .MODE_SEARCH
    var specificData = "ES|<ALL>"
    var fullscreen = true
    var documentType: SelphIDDocumentType = .ID_CARD
    var documentSide: SelphIDDocumentSide = .FRONT
    var generateRawImages = false
}

struct SelphIDComponentCard: View {
    let enabled: Bool
    let title: String
    let desc: String
    let buttonText: String
    let result: UIComponentResult
    let onLaunch: (SelphIDLaunchOptions) -> Void

    @State private var options = SelphIDLaunchOptions()
    @State private var expanded = false

    var body: some View {
        DemoCard(title: title, desc: desc) {
            AdvancedConfigurationSection(expanded: $expanded) {
                HStack(spacing: 12) {
                    BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                    BaseCheckView(text: "onboarding_show_tutorial".localized, isOn: $options.showTutorial)
                }
                .opacity(enabled ? 1 : 0.6)

                HStack(spacing: 12) {
                    BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
                    BaseCheckView(text: "Fullscreen", isOn: $options.fullscreen)
                }
                .opacity(enabled ? 1 : 0.6)

                HStack(spacing: 12) {
                    BaseCheckView(text: "Wizard mode", isOn: $options.wizardMode)
                    BaseCheckView(text: "Show result after capture", isOn: $options.showResultAfterCapture)
                }
                .opacity(enabled ? 1 : 0.6)

                HStack(spacing: 12) {
                    BaseCheckView(text: "Generate raw images", isOn: $options.generateRawImages)
                }
                .opacity(enabled ? 1 : 0.6)

                DropdownField(
                    label: "Select scan mode",
                    options: SelphIDScanMode.allCases,
                    selection: $options.scanMode,
                    enabled: enabled
                ) { $0.rawValue }

                OutlinedTextField(
                    label: "Specific data",
                    text: $options.specificData,
                    enabled: enabled
                )

                DropdownField(
                    label: "Select document type",
                    options: SelphIDDocumentType.allCases,
                    selection: $options.documentType,
                    enabled: enabled
                ) { $0.rawValue }

                OptionLabel(text: "Document side")
                ChipSelector(options: SelphIDDocumentSide.allCases, selection: $options.documentSide, enabled: enabled) {
                    $0.rawValue
                }
            }

            BaseButton(text: buttonText, enabled: enabled) {
                onLaunch(options)
            }

            ResultRow(result: result)
        }
    }
}
