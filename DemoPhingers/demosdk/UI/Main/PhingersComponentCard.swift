//
//  PhingersComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/BaseComponentCard.kt (DemoPhingers).
//

import phingersTFComponent
import SwiftUI

struct PhingersLaunchOptions {
    var showPreviousTip = true
    var showDiagnostic = true
    var liveness = true
    var showPreviousFingerSelector = false
    var captureOrientation: ReticleOrientation = .LEFT
    var fingerFilter: FingerFilter = .SLAP
}

/// Same order as Android FingerFilter.values().
private let fingerFilterOptions: [FingerFilter] = [
    .SLAP,
    .ALL_4_FINGERS_ONE_BY_ONE,
    .ALL_5_FINGERS_ONE_BY_ONE,
    .INDEX_FINGER,
    .MIDDLE_FINGER,
    .RING_FINGER,
    .LITTLE_FINGER,
    .THUMB_FINGER
]

private func fingerFilterLabel(_ filter: FingerFilter) -> String {
    switch filter {
    case .SLAP: return "onboarding_fingerfilter_slap".localized
    case .ALL_4_FINGERS_ONE_BY_ONE: return "onboarding_fingerfilter_all_4_fingers_one_by_one".localized
    case .ALL_5_FINGERS_ONE_BY_ONE: return "onboarding_fingerfilter_all_5_fingers_one_by_one".localized
    case .INDEX_FINGER: return "onboarding_fingerfilter_index_finger".localized
    case .MIDDLE_FINGER: return "onboarding_fingerfilter_middle_finger".localized
    case .RING_FINGER: return "onboarding_fingerfilter_ring_finger".localized
    case .LITTLE_FINGER: return "onboarding_fingerfilter_little_finger".localized
    case .THUMB_FINGER: return "onboarding_fingerfilter_thumb_finger".localized
    @unknown default: return filter.rawValue
    }
}

struct PhingersComponentCard: View {
    let enabled: Bool
    let title: String
    let desc: String
    let buttonText: String
    let result: UIComponentResult
    let onLaunch: (PhingersLaunchOptions) -> Void

    @State private var options = PhingersLaunchOptions()

    var body: some View {
        DemoCard(title: title, desc: desc) {
            HStack(spacing: 12) {
                BaseCheckView(text: "onboarding_show_previous_tip".localized, isOn: $options.showPreviousTip)
                BaseCheckView(text: "onboarding_show_diagnostic".localized, isOn: $options.showDiagnostic)
            }
            .opacity(enabled ? 1 : 0.6)

            HStack(spacing: 12) {
                BaseCheckView(text: "Liveness", isOn: $options.liveness)
                BaseCheckView(text: "onboarding_show_selector_screen".localized, isOn: $options.showPreviousFingerSelector)
            }
            .opacity(enabled ? 1 : 0.6)

            VStack(alignment: .leading, spacing: 8) {
                OptionLabel(text: "onboarding_choose_hand".localized)
                ChipSelector(options: [ReticleOrientation.LEFT, .RIGHT], selection: $options.captureOrientation, enabled: enabled) {
                    $0 == .LEFT ? "onboarding_left".localized : "onboarding_right".localized
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                OptionLabel(text: "onboarding_choose_filter".localized)
                    .opacity(enabled ? 1 : 0.6)
                DropdownField(
                    label: "onboarding_choose_filter".localized,
                    options: fingerFilterOptions,
                    selection: $options.fingerFilter,
                    enabled: enabled
                ) { fingerFilterLabel($0) }
            }

            BaseButton(text: buttonText, enabled: enabled) {
                onLaunch(options)
            }

            ResultRow(result: result)
        }
    }
}
