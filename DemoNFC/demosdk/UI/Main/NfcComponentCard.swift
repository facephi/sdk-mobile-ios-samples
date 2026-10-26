//
//  NfcComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/NfcComponentCard.kt (DemoNFC).
//

import nfcComponent
import SwiftUI

struct NfcComponentCard: View {
    let enabled: Bool
    let title: String
    let result: UIComponentResult
    let onLaunch: (NfcConfigurationData) -> Void

    @State private var options = NfcLaunchOptions()
    @State private var expanded = false
    @State private var support = ""
    @State private var birthDate = ""
    @State private var expirationDate = ""
    @State private var documentType: DocumentType = .ID_CARD

    private var dataValid: Bool {
        !support.isEmpty && birthDate.validNfcDate() && expirationDate.validNfcDate()
    }

    var body: some View {
        DemoCard(title: title) {
            DocumentDataCard(
                support: $support,
                birthDate: $birthDate,
                expirationDate: $expirationDate,
                documentType: $documentType
            )

            Spacer().frame(height: 8)

            NfcConfigurationSection(enabled: enabled, options: $options, expanded: $expanded)

            Spacer().frame(height: 8)

            VStack(spacing: 8) {
                BaseButton(text: "nfc_simple_launch".localized, enabled: dataValid) {
                    launch(skipPACE: true)
                }
                BaseButton(text: "nfc_complex_launch".localized, enabled: dataValid) {
                    launch(skipPACE: false)
                }
            }

            ResultRow(result: result)
        }
    }

    private func launch(skipPACE: Bool) {
        print("APP - LAUNCH NFC \n Support: \(support) \n birthDate: \(birthDate) \n expirationDate: \(expirationDate)")
        let configuration = SdkConfigurationManager.getNfcConfig(
            support: support,
            birthDate: birthDate,
            expirationDate: expirationDate,
            showPreviousTip: options.showPreviousTip,
            showTutorial: options.showTutorial,
            showDiagnostic: options.showDiagnostic,
            skipPACE: skipPACE,
            extractFace: options.extractFace,
            extractSignature: options.extractSignature,
            docType: documentType,
            readingProgressStyle: options.readingProgressStyle,
            maxAttempts: options.maxAttempts
        )
        onLaunch(configuration)
    }
}
