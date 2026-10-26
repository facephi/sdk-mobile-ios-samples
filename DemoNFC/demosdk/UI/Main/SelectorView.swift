//
//  SelectorView.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/base/SelectorView.kt (DemoNFC).
//

import nfcComponent
import SwiftUI

extension DocumentType {
    var displayName: String {
        switch self {
        case .ID_CARD: return "nfc_id_card".localized
        case .PASSPORT: return "nfc_passport".localized
        case .FOREIGN_CARD: return "nfc_foreign_card".localized
        }
    }
}

extension ReadingProgressStyle {
    var displayName: String {
        switch self {
        case .DOTS: return "nfc_dots".localized
        case .PERCENTAGE: return "nfc_percentage".localized
        @unknown default: return rawValue
        }
    }
}

struct DropdownDocumentMenuBox: View {
    @Binding var selected: DocumentType

    var body: some View {
        DropdownField(
            label: "nfc_select_document".localized,
            options: DocumentType.allCases,
            selection: $selected
        ) { $0.displayName }
    }
}

struct DropdownReadingProgress: View {
    @Binding var selected: ReadingProgressStyle

    var body: some View {
        DropdownField(
            label: "nfc_select_progress".localized,
            options: ReadingProgressStyle.allCases,
            selection: $selected
        ) { $0.displayName }
    }
}
