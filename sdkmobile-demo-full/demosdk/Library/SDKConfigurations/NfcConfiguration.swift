//
//  NfcConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import UIKit
import nfcComponent

extension SdkConfigurationManager {
    static var nfcConfiguration: NfcConfigurationData {
        // Dates are in dd/MM/yyyy format
        return NfcConfigurationData(documentNumber: PrefManager.get(String.self, forKey: .KEY_NFC_SUPPORT_NUMBER) ?? "",
                                    birthDate: PrefManager.get(String.self, forKey: .KEY_NFC_BIRTH_DATE) ?? "",
                                    expirationDate: PrefManager.get(String.self, forKey: .KEY_NFC_EXPIRATION_DATE) ?? "",
                                    issuer: PrefManager.get(String.self, forKey: .KEY_NFC_ISSUER) ?? "ES",
                                    documentType: PrefManager.get(.ID_CARD, forKey: .KEY_NFC_DOCUMENT_TYPE),
                                    showTutorial: false, showPreviousTip: true)
    }
}

extension SdkConfigurationManager {
    static func persistNfcConfigurationData(_ configuration: NfcConfigurationData) {
        PrefManager.set(configuration.documentNumber ?? "", forKey: .KEY_NFC_SUPPORT_NUMBER)
        PrefManager.set(configuration.birthDate ?? "", forKey: .KEY_NFC_BIRTH_DATE)
        PrefManager.set(configuration.expirationDate ?? "", forKey: .KEY_NFC_EXPIRATION_DATE)
        PrefManager.set(configuration.issuer ?? "ES", forKey: .KEY_NFC_ISSUER)
        PrefManager.set(configuration.documentType?.rawValue, forKey: .KEY_NFC_DOCUMENT_TYPE)
    }

    static func createNfcConfigurationData(from configuration: Configuration) -> NfcConfigurationData {
        var documentNumber: String?
        var birthDate: String?
        var expirationDate: String?
        var issuer: String?
        var documentType: NfcDocumentType?
        var extractionTimeout: Int?
        var skipPACE: Bool?
        var onlyPACE: Bool?
        var activeAuthenticationChallenge: [UInt8]?
        var extractFacialImage: Bool?
        var extractSignatureImage: Bool?
        var showTutorial: Bool?
        var showDiagnostic: Bool?
        var showPreviousTip: Bool?
        var vibrationEnabled: Bool?
        var readingProgressStyle: ReadingProgressStyle?
        var tagSessionTimeout: Int?

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("documentNumber", .string(let val)):
                documentNumber = val
            case ("birthDate", .string(let val)):
                birthDate = val
            case ("expirationDate", .string(let val)):
                expirationDate = val
            case ("issuer", .string(let val)):
                issuer = val
            case ("documentType", .enumValue(let val, _)):
                documentType = NfcDocumentType(rawValue: val)
            case ("extractionTimeout", .int(let val)):
                extractionTimeout = val
            case ("skipPACE", .bool(let val)):
                skipPACE = val
            case ("onlyPACE", .bool(let val)):
                onlyPACE = val
            case ("activeAuthenticationChallenge", .string(let val)):
                activeAuthenticationChallenge = parseActiveAuthenticationChallenge(val)
            case ("extractFacialImage", .bool(let val)):
                extractFacialImage = val
            case ("extractSignatureImage", .bool(let val)):
                extractSignatureImage = val
            case ("showTutorial", .bool(let val)):
                showTutorial = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            case ("showPreviousTip", .bool(let val)):
                showPreviousTip = val
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("readingProgressStyle", .enumValue(let val, _)):
                readingProgressStyle = ReadingProgressStyle(rawValue: val)
            case ("tagSessionTimeout", .int(let val)):
                tagSessionTimeout = val
            default:
                break
            }
        }

        return NfcConfigurationData(
            documentNumber: documentNumber ?? "",
            birthDate: birthDate ?? "",
            expirationDate: expirationDate ?? "",
            issuer: issuer ?? "ES",
            documentType: documentType ?? .ID_CARD,
            extractionTimeout: extractionTimeout ?? 58000,
            skipPACE: skipPACE ?? false,
            onlyPACE: onlyPACE ?? false,
            activeAuthenticationChallenge: activeAuthenticationChallenge,
            extractFacialImage: extractFacialImage ?? true,
            extractSignatureImage: extractSignatureImage ?? false,
            showTutorial: showTutorial ?? false,
            showDiagnostic: showDiagnostic ?? true,
            showPreviousTip: showPreviousTip ?? true,
            vibrationEnabled: vibrationEnabled ?? true,
            readingProgressStyle: readingProgressStyle ?? .DOTS,
            tagSessionTimeout: tagSessionTimeout ?? 1500
        )
    }

    static func configureNfcFields(in viewController: ConfigsComponentsVC,
                                   with nfcConfigurationData: NfcConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .NFC_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "documentNumber": .string(value: nfcConfigurationData?.documentNumber ?? nfcConfiguration.documentNumber ?? ""),
            "birthDate": .string(value: nfcConfigurationData?.birthDate ?? nfcConfiguration.birthDate ?? ""),
            "expirationDate": .string(value: nfcConfigurationData?.expirationDate ?? nfcConfiguration.expirationDate ?? ""),
            "issuer": .string(value: nfcConfigurationData?.issuer ?? nfcConfiguration.issuer ?? "ES"),
            "documentType": .enumValue(
                value: (nfcConfigurationData?.documentType ?? nfcConfiguration.documentType ?? .ID_CARD).rawValue,
                options: NfcDocumentType.allCases.map { $0.rawValue }
            ),
            "extractionTimeout": .int(value: nfcConfigurationData?.extractionTimeout ?? nfcConfiguration.extractionTimeout),
            "skipPACE": .bool(value: nfcConfigurationData?.skipPACE ?? nfcConfiguration.skipPACE),
            "onlyPACE": .bool(value: nfcConfigurationData?.onlyPACE ?? nfcConfiguration.onlyPACE ?? false),
            "activeAuthenticationChallenge": .string(value: formatActiveAuthenticationChallenge(nfcConfigurationData?.activeAuthenticationChallenge ?? nfcConfiguration.activeAuthenticationChallenge)),
            "extractFacialImage": .bool(value: nfcConfigurationData?.extractFacialImage ?? nfcConfiguration.extractFacialImage),
            "extractSignatureImage": .bool(value: nfcConfigurationData?.extractSignatureImage ?? nfcConfiguration.extractSignatureImage),
            "showTutorial": .bool(value: nfcConfigurationData?.showTutorial ?? nfcConfiguration.showTutorial),
            "showDiagnostic": .bool(value: nfcConfigurationData?.showDiagnostic ?? nfcConfiguration.showDiagnostic),
            "showPreviousTip": .bool(value: nfcConfigurationData?.showPreviousTip ?? nfcConfiguration.showPreviousTip),
            "vibrationEnabled": .bool(value: nfcConfigurationData?.vibrationEnabled ?? nfcConfiguration.vibrationEnabled),
            "readingProgressStyle": .enumValue(
                value: (nfcConfigurationData?.readingProgressStyle ?? nfcConfiguration.readingProgressStyle ?? .DOTS).rawValue,
                options: ReadingProgressStyle.allCases.map { $0.rawValue }
            ),
            "tagSessionTimeout": .int(value: nfcConfigurationData?.tagSessionTimeout ?? nfcConfiguration.tagSessionTimeout ?? 1500)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "showTutorial",
            "showDiagnostic",
            "showPreviousTip",
            "vibrationEnabled",
            "skipPACE",
            "onlyPACE",
            "extractFacialImage",
            "extractSignatureImage"
        ]

        var rowStackView: UIStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.alignment = .fill
        rowStackView.distribution = .fillEqually
        rowStackView.spacing = 16

        for (index, key) in switchKeys.enumerated() {
            if let value = viewController.configuration!.values[key] {
                rowStackView.addArrangedSubview(viewController.createField(key: key, value: value))
                if (index + 1) % 2 == 0 || index == switchKeys.count - 1 {
                    stackView.addArrangedSubview(rowStackView)
                    if index != switchKeys.count - 1 {
                        rowStackView = UIStackView()
                        rowStackView.axis = .horizontal
                        rowStackView.alignment = .fill
                        rowStackView.distribution = .fillEqually
                        rowStackView.spacing = 16
                    }
                }
            }
        }

        let fieldKeys: [String] = [
            "documentType",
            "documentNumber",
            "birthDate",
            "expirationDate",
            "issuer",
            "extractionTimeout",
            "tagSessionTimeout",
            "readingProgressStyle",
            "activeAuthenticationChallenge"
        ]

        for key in fieldKeys {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }

    private static func parseActiveAuthenticationChallenge(_ value: String) -> [UInt8]? {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedValue.isEmpty,
           !trimmedValue.contains(where: { $0 == "," || $0 == " " || $0 == "\n" || $0 == "\t" }),
           trimmedValue.count.isMultiple(of: 2) {
            let bytes = stride(from: 0, to: trimmedValue.count, by: 2).compactMap { index -> UInt8? in
                let start = trimmedValue.index(trimmedValue.startIndex, offsetBy: index)
                let end = trimmedValue.index(start, offsetBy: 2)
                return UInt8(trimmedValue[start..<end], radix: 16)
            }

            return bytes.count == trimmedValue.count / 2 ? bytes : nil
        }

        let bytes = value
            .split { $0 == "," || $0 == " " || $0 == "\n" || $0 == "\t" }
            .compactMap { byte -> UInt8? in
                let token = byte.trimmingCharacters(in: .whitespacesAndNewlines)
                if token.hasPrefix("0x") || token.hasPrefix("0X") {
                    return UInt8(token.dropFirst(2), radix: 16)
                }
                return UInt8(token)
            }

        return bytes.isEmpty ? nil : bytes
    }

    private static func formatActiveAuthenticationChallenge(_ value: [UInt8]?) -> String {
        value?.map(String.init).joined(separator: ",") ?? ""
    }
}
