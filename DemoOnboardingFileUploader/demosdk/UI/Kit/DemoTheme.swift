//
//  DemoTheme.swift
//  demosdk
//
//  SwiftUI port of the Android samples theme (ui/theme + res/values/sdk_style.xml).
//  Shared across the iOS samples: keep it identical in every demo.
//

import CoreText
import SwiftUI

// MARK: - Colors (Assets.xcassets colorsets mirror sdk_style.xml light / night)

extension Color {
    static let sdkPrimary = Color("sdkPrimaryColor")
    static let sdkBackground = Color("sdkBackgroundColor")
    static let sdkTitleText = Color("sdkTitleTextColor")
    static let sdkBodyText = Color("sdkBodyTextColor")
    static let sdkButtonText = Color("sdkButtonTextColor")
    static let sdkError = Color("sdkErrorColor")

    /// Material3 colorScheme equivalents used by the Android composables.
    static let demoOnSurface = Color(.label)
    static let demoOnSurfaceVariant = Color(.secondaryLabel)
    static let demoOutline = Color(.systemGray)
    static let demoOutlineVariant = Color(.separator)
    static let demoSurfaceVariant = Color(.systemGray5)

    static let demoResultOk = Color(red: 0x2E / 255, green: 0x7D / 255, blue: 0x32 / 255)
    static let demoResultError = Color(red: 0xC6 / 255, green: 0x28 / 255, blue: 0x28 / 255)
}

// MARK: - Fonts (res/font/sdk_font*.ttf → Poppins)

enum DemoFont {
    private static let files = ["sdk_font", "sdk_font_light", "sdk_font_semibold", "sdk_font_bold"]

    /// Registers the bundled SDK fonts. Call once at app start.
    static func register() {
        for file in files {
            guard let url = Bundle.main.url(forResource: file, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    /// `appFontFamily` on Android.
    static func app(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .light: name = "Poppins-Light"
        case .semibold: name = "Poppins-SemiBold"
        case .bold, .heavy, .black: name = "Poppins-Bold"
        default: name = "Poppins-Regular"
        }
        return .custom(name, size: size)
    }
}

// MARK: - Typography (Material3 defaults used by the Android cards)

extension Font {
    static let demoTitleMedium = Font.system(size: 16, weight: .medium)
    static let demoBodyMedium = Font.system(size: 14)
    static let demoBodySmall = Font.system(size: 12)
    static let demoLabelLarge = Font.system(size: 14, weight: .medium)
}
