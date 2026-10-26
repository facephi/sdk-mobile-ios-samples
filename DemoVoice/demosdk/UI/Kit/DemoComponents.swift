//
//  DemoComponents.swift
//  demosdk
//
//  SwiftUI port of the Android samples composables
//  (BaseButton, BaseTextButton, BaseCheckView, ButtonCard, StartAndStopCard, ResultRow, FilterChip,
//  ExposedDropdown, OutlinedTextField, SettingStepperRow, MediaCard...).
//  Shared across the iOS samples: keep it identical in every demo.
//

import SwiftUI

// MARK: - UIComponentResult

enum UIComponentResult {
    case pending, ok, error
}

// MARK: - Logo

struct DemoLogo: View {
    var padding: CGFloat = 8

    var body: some View {
        Image("ic_demo_logo")
            .frame(height: 75)
            .padding(padding)
    }
}

// MARK: - BaseButton

struct BaseButton: View {
    let text: String
    var enabled: Bool = true
    /// Android BaseButton(loading = true): shows a progress indicator instead of the text.
    var loading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(width: 32, height: 32)
                } else {
                    Text(text.uppercased())
                        .font(DemoFont.app(16, weight: .semibold))
                        .foregroundColor(enabled ? .white : Color.demoOnSurface.opacity(0.38))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(enabled ? Color.sdkPrimary : Color.demoOnSurface.opacity(0.12))
            )
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// MARK: - BaseTextButton

struct BaseTextButton: View {
    let text: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(DemoFont.app(18, weight: .bold))
                .underline()
                .foregroundColor(.sdkPrimary)
                .padding(.horizontal, 12)
                .frame(minHeight: 40)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// MARK: - BaseCheckView

struct BaseCheckView: View {
    let text: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isOn.toggle() }
        } label: {
            HStack(spacing: 12) {
                Text(text)
                    .font(.demoBodyMedium)
                    .foregroundColor(.demoOnSurface)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundColor(isOn ? .sdkPrimary : .demoOutline)
                    .frame(width: 40, height: 40)
            }
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .padding(.vertical, 2)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isOn ? Color.sdkPrimary.opacity(0.08) : Color.demoSurfaceVariant.opacity(0.3))
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DemoCard (ElevatedCard + title / optional desc / divider)

struct DemoCard<Content: View>: View {
    let title: String
    let desc: String?
    let content: () -> Content

    init(title: String, desc: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.desc = desc
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.demoTitleMedium)
                    .foregroundColor(.demoOnSurface)
                if let desc {
                    Text(desc)
                        .font(.demoBodySmall)
                        .foregroundColor(.demoOnSurfaceVariant)
                }
            }
            Rectangle()
                .fill(Color.demoOutlineVariant)
                .frame(height: 1)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.sdkBackground)
                .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
        )
    }
}

// MARK: - ButtonCard

struct ButtonCard: View {
    let title: String
    let desc: String
    let buttonText: String
    var enabled: Bool = true
    let action: () -> Void

    var body: some View {
        DemoCard(title: title, desc: desc) {
            BaseButton(text: buttonText, enabled: enabled, action: action)
        }
    }
}

// MARK: - StartAndStopCard

struct StartAndStopCard: View {
    let title: String
    let desc: String
    let startButtonText: String
    let stopButtonText: String
    let result: UIComponentResult
    var enabled: Bool = true
    var okLabel: String = "onboarding_result_ok".localized
    var errorLabel: String = "onboarding_result_error".localized
    let onStart: () -> Void
    let onStop: () -> Void

    var body: some View {
        DemoCard(title: title, desc: desc) {
            HStack(spacing: 16) {
                BaseButton(text: startButtonText, enabled: enabled, action: onStart)
                BaseButton(text: stopButtonText, enabled: enabled, action: onStop)
            }
            ResultRow(result: result, okLabel: okLabel, errorLabel: errorLabel)
        }
    }
}

// MARK: - SettingStepperRow

struct SettingStepperRow: View {
    let text: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.sdkBodyText)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)

            stepButton(systemName: "minus", enabled: value > range.lowerBound) {
                value = max(value - 1, range.lowerBound)
            }

            Text(String(value))
                .font(.demoTitleMedium)
                .foregroundColor(.demoOnSurface)
                .frame(minWidth: 32)

            stepButton(systemName: "plus", enabled: value < range.upperBound) {
                value = min(value + 1, range.upperBound)
            }
        }
        .padding(.vertical, 6)
    }

    private func stepButton(systemName: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(enabled ? .demoOnSurfaceVariant : .demoOnSurface.opacity(0.38))
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }
}

// MARK: - ResultRow

/// Android ResultRow(label, ok).
struct ResultRow: View {
    let label: String?
    let ok: Bool

    init(label: String, ok: Bool) {
        self.label = label
        self.ok = ok
    }

    /// Convenience for the Android pattern `if (resultValue != PENDING) ResultRow(label = ok ? okLabel : errorLabel, ok = …)`.
    init(
        result: UIComponentResult,
        okLabel: String = "onboarding_result_ok".localized,
        errorLabel: String = "onboarding_result_error".localized
    ) {
        switch result {
        case .pending: label = nil; ok = false
        case .ok: label = okLabel; ok = true
        case .error: label = errorLabel; ok = false
        }
    }

    var body: some View {
        if let label {
            HStack(spacing: 8) {
                Image(systemName: ok ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(ok ? .demoResultOk : .demoResultError)
                    .frame(width: 20, height: 20)
                Text(label)
                    .font(.demoBodyMedium)
                    .foregroundColor(.demoOnSurface)
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Advanced configuration (expandable section)

struct AdvancedConfigurationSection<Content: View>: View {
    @Binding var expanded: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { expanded.toggle() }
            } label: {
                HStack {
                    Text("onboarding_configuration".localized)
                        .font(.demoBodyMedium)
                        .foregroundColor(.demoOnSurface)
                    Spacer()
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.demoOnSurface)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.demoSurfaceVariant.opacity(0.4))
                )
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if expanded {
                VStack(alignment: .leading, spacing: 12) {
                    content()
                }
                .padding(.top, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Section label (labelLarge)

struct OptionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.demoLabelLarge)
            .foregroundColor(.demoOnSurface)
    }
}

// MARK: - FilterChip row

struct ChipSelector<Value: Hashable>: View {
    let options: [Value]
    @Binding var selection: Value
    var enabled: Bool = true
    let title: (Value) -> String

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                FilterChip(
                    text: title(option),
                    selected: option == selection,
                    action: { if enabled { selection = option } }
                )
            }
        }
        .opacity(enabled ? 1 : 0.6)
    }
}

struct FilterChip: View {
    let text: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if selected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                }
                Text(text)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(.demoOnSurface)
            .padding(.leading, selected ? 8 : 16)
            .padding(.trailing, 16)
            .frame(height: 32)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selected ? Color.sdkPrimary.opacity(0.16) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selected ? Color.clear : Color.demoOutline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - ExposedDropdownMenu (OutlinedTextField + menu)

struct DropdownField<Value: Hashable>: View {
    let label: String
    let options: [Value]
    @Binding var selection: Value
    var enabled: Bool = true
    let title: (Value) -> String

    var body: some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(title(option)) { selection = option }
            }
        } label: {
            HStack {
                Text(title(selection))
                    .font(.system(size: 16))
                    .foregroundColor(.demoOnSurface)
                Spacer()
                Image(systemName: "arrowtriangle.down.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.demoOnSurfaceVariant)
            }
            .padding(.horizontal, 16)
            .frame(height: 56)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.demoOutline, lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.demoOnSurfaceVariant)
                    .padding(.horizontal, 4)
                    .background(Color.sdkBackground)
                    .offset(x: 12, y: -8)
            }
            .contentShape(Rectangle())
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.6)
    }
}

// MARK: - OutlinedTextField (Material3: floating label, error state, supporting text)

struct OutlinedTextField: View {
    let label: String
    @Binding var text: String
    var enabled: Bool = true
    var isError: Bool = false
    var supportingText: String?
    var keyboardType: UIKeyboardType = .default
    var submitLabel: SubmitLabel = .done
    var onSubmit: () -> Void = {}

    @FocusState private var focused: Bool

    private var floating: Bool { focused || !text.isEmpty }

    private var accent: Color {
        if isError { return .sdkError }
        return focused ? .sdkPrimary : .demoOutline
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack(alignment: .leading) {
                TextField("", text: $text)
                    .font(.system(size: 16))
                    .foregroundColor(.demoOnSurface)
                    .keyboardType(keyboardType)
                    .submitLabel(submitLabel)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focused)
                    .onSubmit(onSubmit)
                    .padding(.horizontal, 16)
                    .frame(height: 56)

                Text(label)
                    .font(.system(size: floating ? 12 : 16))
                    .foregroundColor(isError ? .sdkError : (focused ? .sdkPrimary : .demoOnSurfaceVariant))
                    .padding(.horizontal, floating ? 4 : 0)
                    .background(floating ? Color.sdkBackground : Color.clear)
                    .offset(x: floating ? 12 : 16, y: floating ? -28 : 0)
                    .allowsHitTesting(false)
                    .animation(.easeInOut(duration: 0.15), value: floating)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(accent, lineWidth: focused || isError ? 2 : 1)
            )
            .contentShape(Rectangle())
            .onTapGesture { if enabled { focused = true } }

            if let supportingText {
                Text(supportingText)
                    .font(.demoBodySmall)
                    .foregroundColor(isError ? .sdkError : .demoOnSurfaceVariant)
                    .padding(.horizontal, 16)
            }
        }
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.6)
    }
}

// MARK: - MediaCard (Android DemoVoice MediaCard)

struct MediaCard: View {
    let title: String
    let desc: String
    var playText: String = "Play"
    let enabled: Bool
    let isPlaying: Bool
    let audioIndex: Int
    let onPlay: () -> Void
    let onStop: () -> Void

    var body: some View {
        DemoCard(title: title, desc: desc) {
            BaseButton(text: playText, enabled: enabled, action: onPlay)

            if isPlaying {
                HStack(spacing: 0) {
                    Text("AUDIO \(audioIndex)")
                        .font(.system(size: 16))
                        .foregroundColor(.sdkPrimary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)

                    BaseButton(text: "STOP", action: onStop)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

// MARK: - Footer (version + logs + result images)

struct DemoFooter: View {
    let version: String
    let logs: String
    let images: [UIImage]
    let onClearLogs: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text(version)
                .font(.system(size: 16))
                .foregroundColor(.demoOnSurface)
                .frame(maxWidth: .infinity)

            if !logs.isEmpty {
                Spacer().frame(height: 16)
                Rectangle()
                    .fill(Color(.lightGray))
                    .frame(height: 1)
                BaseTextButton(text: "Clear logs", action: onClearLogs)
                Text(logs)
                    .font(.system(size: 14))
                    .foregroundColor(.sdkBodyText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .textSelection(.enabled)
            }

            ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .padding(16)
            }
        }
    }
}

// MARK: - Localization helper

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
