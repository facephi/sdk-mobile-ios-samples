//
//  SelphiComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/SelphiComponentCard.kt.
//

import selphiComponent
import SwiftUI

enum LivenessModeOption: String, CaseIterable {
    case NONE, NONE_STABILIZED, PASSIVE, MOVE

    func toSdkValue(moveSuccessfulAttempts: Int, moveFailedAttempts: Int) -> SelphiFaceLivenessMode {
        switch self {
        case .NONE: return .LIVENESS_NONE
        case .NONE_STABILIZED: return .LIVENESS_NONE_STABILIZED
        case .PASSIVE: return .LIVENESS_PASSIVE
        case .MOVE: return .LIVENESS_MOVE(successfulAttempts: moveSuccessfulAttempts, failedAttempts: moveFailedAttempts)
        }
    }
}

struct SelphiLaunchOptions {
    var showPreviousTip = true
    var showTutorial = true
    var showDiagnostic = true
    var cameraPreferred: SelphiCamera = .FRONT
    var livenessMode: LivenessModeOption = .PASSIVE
    var moveSuccessfulAttempts = 1
    var moveFailedAttempts = 2
    var maxAttempts = 3
    var iadEnabled = false
}

private let maxAttemptsOptions = [1, 3, 5, 0]
private let moveAttemptsOptions = [1, 2, 3]

struct SelphiComponentCard: View {
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
                HStack(spacing: 12) {
                    BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                    BaseCheckView(text: "onboarding_show_tutorial".localized, isOn: $options.showTutorial)
                }
                .opacity(enabled ? 1 : 0.6)

                BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
                    .fixedSize(horizontal: true, vertical: false)
                    .opacity(enabled ? 1 : 0.6)

                OptionLabel(text: "Camera")
                ChipSelector(options: SelphiCamera.allCases, selection: $options.cameraPreferred, enabled: enabled) {
                    $0.rawValue
                }

                DropdownField(
                    label: "Liveness mode",
                    options: LivenessModeOption.allCases,
                    selection: $options.livenessMode,
                    enabled: enabled
                ) { $0.rawValue }

                if options.livenessMode == .MOVE {
                    VStack(alignment: .leading, spacing: 12) {
                        OptionLabel(text: "Move: successful attempts")
                        ChipSelector(options: moveAttemptsOptions, selection: $options.moveSuccessfulAttempts, enabled: enabled) {
                            String($0)
                        }
                        OptionLabel(text: "Move: failed attempts")
                        ChipSelector(options: moveAttemptsOptions, selection: $options.moveFailedAttempts, enabled: enabled) {
                            String($0)
                        }
                    }
                    .transition(.opacity)
                }

                OptionLabel(text: "Max attempts (0 = unlimited)")
                ChipSelector(options: maxAttemptsOptions, selection: $options.maxAttempts, enabled: enabled) {
                    $0 == 0 ? "Unlimited" : String($0)
                }

                BaseCheckView(text: "IAD (injection attack detection)", isOn: $options.iadEnabled)
                    .fixedSize(horizontal: true, vertical: false)
                    .opacity(enabled ? 1 : 0.6)
            }

            BaseButton(text: buttonText, enabled: enabled) {
                onLaunch(options)
            }

            ResultRow(result: result)
        }
    }
}
