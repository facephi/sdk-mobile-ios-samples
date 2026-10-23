//
//  NfcTheme.swift
//  demosdk
//
//  SwiftUI port of Android ui/theme/Theme.kt (DemoNFC): fixed light / dark colour scheme.
//

import SwiftUI
import UIKit

extension Color {
    static let nfcPrimary = Color.nfcDynamic(light: 0x3167FC, dark: 0x8AB4FF)
    static let nfcSurface = Color.nfcDynamic(light: 0xFFFFFF, dark: 0x1E1E1E)
    static let nfcSurfaceVariant = Color.nfcDynamic(light: 0xF2F4F8, dark: 0x2A2A2A)
    static let nfcOnSurface = Color.nfcDynamic(light: 0x1D2C4D, dark: 0xFFFFFF)
    static let nfcOnSurfaceVariant = Color.nfcDynamic(light: 0x526080, dark: 0xE5E7EB)
    static let nfcOutline = Color.nfcDynamic(light: 0x6B7280, dark: 0x9CA3AF)
    static let nfcOutlineVariant = Color.nfcDynamic(light: 0xD6DAE5, dark: 0x3A3A3A)
    static let nfcError = Color.nfcDynamic(light: 0xDD3631, dark: 0xDD3631)

    private static func nfcDynamic(light: UInt32, dark: UInt32) -> Color {
        Color(UIColor { traits in
            UIColor(nfcHex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

private extension UIColor {
    convenience init(nfcHex hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
