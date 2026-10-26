//
//  SelphIDNfcComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/SelphIDNfcComponentCard.kt (DemoNFC).
//

import nfcComponent
import SwiftUI

struct SelphIDNfcComponentCard: View {
    let enabled: Bool
    let title: String
    let result: UIComponentResult
    let onLaunch: (_ options: NfcLaunchOptions, _ documentType: DocumentType, _ skipPACE: Bool) -> Void

    @State private var options = NfcLaunchOptions()
    @State private var documentType: DocumentType = .ID_CARD
    @State private var expanded = false

    var body: some View {
        DemoCard(title: title) {
            DropdownDocumentMenuBox(selected: $documentType)
                .padding(.top, 8)

            HStack(spacing: 0) {
                Image("ic_nfc_id_back_id")
                    .padding(.leading, 16)
                Text("nfc_data_selphid_desc".localized)
                    .font(.demoBodySmall)
                    .foregroundColor(.nfcOnSurfaceVariant)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.sdkBackground)
                    .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
            )

            Spacer().frame(height: 4)

            NfcConfigurationSection(enabled: enabled, options: $options, expanded: $expanded)

            Spacer().frame(height: 8)

            VStack(spacing: 8) {
                BaseButton(text: "nfc_simple_launch".localized, enabled: enabled) {
                    print("APP - LAUNCH Simple SelphID+NFC")
                    onLaunch(options, documentType, true)
                }
                BaseButton(text: "nfc_complex_launch".localized, enabled: enabled) {
                    print("APP - LAUNCH Complex SelphID+NFC")
                    onLaunch(options, documentType, false)
                }
            }

            ResultRow(result: result)
        }
    }
}
