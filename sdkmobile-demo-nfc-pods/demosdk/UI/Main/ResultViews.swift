//
//  ResultViews.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/result/ErrorRow.kt, LoadingRow.kt and PersonalInfoCard.kt (DemoNFC).
//

import nfcComponent
import SwiftUI

struct ErrorRow: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 20))
                .foregroundColor(.nfcError)
            Text(message)
                .font(.demoBodyMedium)
                .foregroundColor(.nfcError)
                .lineLimit(2)
                .truncationMode(.tail)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}

struct LoadingRow: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(.nfcPrimary)
            Text("Loading...")
                .font(.demoBodyMedium)
                .foregroundColor(.nfcPrimary)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
    }
}

struct PersonalInfoCard: View {
    let info: NfcPersonalInformation

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("nfc_info_title".localized)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.nfcPrimary)

            Rectangle()
                .fill(Color.nfcOutlineVariant)
                .frame(height: 1)

            InfoRow(label: "nfc_info_name".localized, value: info.name)
            InfoRow(label: "nfc_info_surname".localized, value: info.surname)
            InfoRow(label: "nfc_info_number".localized, value: info.personalNumber)
            InfoRow(label: "nfc_info_nationality".localized, value: info.nationality)
            InfoRow(label: "nfc_info_gender".localized, value: info.gender)
            InfoRow(label: "nfc_info_birth_date".localized, value: Self.formatBirthDate(info.birthdate ?? ""))
            InfoRow(label: "nfc_info_birth_place".localized, value: info.placeOfBirth)
            InfoRow(label: "nfc_info_address".localized, value: info.address)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.nfcSurface)
                .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
        )
        .padding(16)
    }

    private static func formatBirthDate(_ raw: String) -> String {
        guard raw.count == 6, raw.allSatisfy(\.isNumber) else { return raw }
        let chars = Array(raw)
        return "\(String(chars[0...1]))-\(String(chars[2...3]))-\(String(chars[4...5]))"
    }
}

private struct InfoRow: View {
    let label: String
    let value: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.nfcOnSurfaceVariant)
            Text(displayValue)
                .font(.demoBodyMedium)
                .foregroundColor(.nfcOnSurface)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.nfcSurfaceVariant.opacity(0.5))
                )
        }
    }

    private var displayValue: String {
        let trimmed = (value ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "—" : (value ?? "")
    }
}
