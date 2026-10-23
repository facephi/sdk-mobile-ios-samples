//
//  DocumentDataCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/DocumentDataCard.kt + utils/Extensions.kt (DemoNFC).
//

import SwiftUI

struct DocumentDataCard: View {
    @Binding var support: String
    @Binding var birthDate: String
    @Binding var expirationDate: String
    @Binding var documentType: DocumentType

    // Errors are only shown after the user has touched the field
    @State private var supportTouched = false
    @State private var birthTouched = false
    @State private var expiryTouched = false

    var body: some View {
        let supportError = supportTouched && support.isEmpty
        let birthError = birthTouched && !birthDate.validNfcDate()
        let expiryError = expiryTouched && !expirationDate.validNfcDate()

        VStack(alignment: .leading, spacing: 4) {
            Text("nfc_data_desc".localized)
                .font(.demoBodyMedium)
                .foregroundColor(.nfcOnSurfaceVariant)
                .padding(.bottom, 8)

            OutlinedTextField(
                label: "nfc_num_support".localized,
                text: $support,
                isError: supportError,
                supportingText: supportError ? "nfc_data_mandatory".localized : nil
            )
            .onChange(of: support) { _ in supportTouched = true }
            .padding(.top, 8)

            OutlinedTextField(
                label: "nfc_birth_date".localized,
                text: $birthDate,
                isError: birthError,
                supportingText: birthError ? "nfc_data_date_error".localized : nil,
                keyboardType: .numberPad
            )
            .onChange(of: birthDate) { value in
                birthTouched = true
                let formatted = value.formatAsDate()
                if formatted != value { birthDate = formatted }
            }
            .padding(.top, 12)

            OutlinedTextField(
                label: "nfc_expiry_date".localized,
                text: $expirationDate,
                isError: expiryError,
                supportingText: expiryError ? "nfc_data_date_error".localized : nil,
                keyboardType: .numberPad,
                submitLabel: .done
            )
            .onChange(of: expirationDate) { value in
                expiryTouched = true
                let formatted = value.formatAsDate()
                if formatted != value { expirationDate = formatted }
            }
            .padding(.top, 12)

            DropdownDocumentMenuBox(selected: $documentType)
                .padding(.top, 16)
        }
    }
}

extension String {
    /// Same as Android String.formatAsDate(): keeps digits and inserts "/" -> dd/MM/yyyy.
    func formatAsDate() -> String {
        let s = String(filter(\.isNumber).prefix(8))
        switch s.count {
        case 0...2: return s
        case 3...4: return "\(s.prefix(2))/\(s.dropFirst(2))"
        default:
            let chars = Array(s)
            return "\(String(chars[0..<2]))/\(String(chars[2..<4]))/\(String(chars[4...]))"
        }
    }

    /// Same as Android String.validNfcDate(): dd/MM/yyyy and a real calendar date.
    func validNfcDate() -> Bool {
        guard range(of: #"^\d{2}/\d{2}/\d{4}$"#, options: .regularExpression) != nil else { return false }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.isLenient = false
        guard let date = formatter.date(from: self) else { return false }
        return formatter.string(from: date) == self
    }
}
