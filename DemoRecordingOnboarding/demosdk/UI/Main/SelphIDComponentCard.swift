//
//  SelphIDComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/SelphIDComponentCard.kt.
//

import selphidComponent
import SwiftUI

enum CaptureModeOption: String, CaseIterable {
    case STANDARD, FRONT, MRZ, STEP_SIDE

    func toSdkValue() -> SelphIDCaptureMode {
        switch self {
        case .STANDARD: return .STANDARD
        case .FRONT: return .FRONT
        case .MRZ: return .MRZ
        case .STEP_SIDE: return .STEP_SIDE(clean: false)
        }
    }
}

struct SelphIDLaunchOptions {
    var showPreviousTip = true
    var showTutorial = true
    var showDiagnostic = true
    var showDocumentSelector = true
    var showResultAfterCapture = true
    var documentType: SelphIDDocumentType = .ALL
    var captureMode: CaptureModeOption = .STANDARD
    var generateRawImages = false
    var maxAttempts = 3
}

private let maxAttemptsOptions = [1, 3, 5, 0]

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
                Group {
                    HStack(spacing: 12) {
                        BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                        BaseCheckView(text: "onboarding_show_tutorial".localized, isOn: $options.showTutorial)
                    }
                    BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
                    HStack(spacing: 12) {
                        BaseCheckView(text: "Show document selector", isOn: $options.showDocumentSelector)
                        BaseCheckView(text: "Show result after capture", isOn: $options.showResultAfterCapture)
                    }
                    BaseCheckView(text: "Generate raw images", isOn: $options.generateRawImages)
                }
                .opacity(enabled ? 1 : 0.6)

                DropdownField(
                    label: "Select document type",
                    options: SelphIDDocumentType.allCases,
                    selection: $options.documentType,
                    enabled: enabled
                ) { String(describing: $0) }

                DropdownField(
                    label: "Select capture mode",
                    options: CaptureModeOption.allCases,
                    selection: $options.captureMode,
                    enabled: enabled
                ) { $0.rawValue }

                OptionLabel(text: "Max attempts (0 = unlimited)")
                ChipSelector(options: maxAttemptsOptions, selection: $options.maxAttempts, enabled: enabled) {
                    $0 == 0 ? "Unlimited" : String($0)
                }
            }

            BaseButton(text: buttonText, enabled: enabled) {
                onLaunch(options)
            }

            ResultRow(result: result)
        }
    }
}
