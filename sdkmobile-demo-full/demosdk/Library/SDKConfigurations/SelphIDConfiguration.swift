//
//  SelphIDConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphidComponent
import UIKit
import core

extension SdkConfigurationManager {
    private static let selphIDCaptureModeNames = ["FRONT", "STANDARD", "MRZ", "STEP_SIDE"]

    static var selphIDConfiguration: SelphIDConfigurationData {
        var config = SelphIDConfigurationData()
        let docType: SelphIDDocumentType = PrefManager.get(.ID_CARD, forKey: .KEY_NFC_DOCUMENT_TYPE)

        config.uiConfiguration.showAfterCapture = true
        config.uiConfiguration.showDocumentSelector = true
        config.uiConfiguration.defaultCountry = "ES"
        config.uiConfiguration.defaultDocumentType = docType
        config.uiConfiguration.enabledDocumentTypes = [.ID_CARD, .PASSPORT, .FOREIGN_CARD, .DRIVERS_LICENSE]

        config.extractionConfiguration.captureMode = .STANDARD
        config.extractionConfiguration.documentCountries = ["ES"]
        config.extractionConfiguration.documentTypes = [docType]
        config.extractionConfiguration.generateRawImages = true

        config.orientation = .FOLLOW_SYSTEM
        config.timeout = SelphIDTimeout.MEDIUM.milliseconds
        config.extractorSelection.mode = .INTERNAL_WEIGHTED
        config.extractorSelection.preferredVendors = [.EXTRACTOR_V3, .EXTRACTOR_V1, .EXTRACTOR_V2]

        return config
    }
}

extension SdkConfigurationManager {
    // swiftlint:disable all
    static func createSelphidConfigurationData(from configuration: Configuration) -> SelphIDConfigurationData {
        var config = SelphIDConfigurationData()
        var captureModeName = "FRONT"
        var stepSideClean = false
        var videoFilename = ""
        var videoBitRate = SelphIDVideoBitRate.LOW
        var videoCustomBitRate: Int32 = 0

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("showTutorial", .bool(let val)):
                config.uiConfiguration.showTutorial = val
            case ("showPreviousTip", .bool(let val)):
                config.uiConfiguration.showPreviousTip = val
            case ("showDiagnostic", .bool(let val)):
                config.uiConfiguration.showDiagnostic = val
            case ("showAfterCapture", .bool(let val)):
                config.uiConfiguration.showAfterCapture = val
            case ("showDocumentSelector", .bool(let val)):
                config.uiConfiguration.showDocumentSelector = val
            case ("showTutorialOnly", .bool(let val)):
                config.uiConfiguration.showTutorialOnly = val
            case ("defaultCountry", .string(let val)):
                config.uiConfiguration.defaultCountry = val.nilIfBlank
            case ("defaultDocumentType", .enumValue(let val, _)):
                config.uiConfiguration.defaultDocumentType = SelphIDDocumentType(rawValue: val)
            case ("enabledCountries", .string(let val)):
                config.uiConfiguration.enabledCountries = csvList(val).nilIfEmpty
            case ("enabledDocumentTypes", .string(let val)):
                config.uiConfiguration.enabledDocumentTypes = csvEnums(val).nilIfEmpty
            case ("captureMode", .enumValue(let val, _)):
                captureModeName = val
            case ("captureModeStepSideClean", .bool(let val)):
                stepSideClean = val
            case ("documentCountries", .string(let val)):
                let countries = csvList(val)
                config.extractionConfiguration.documentCountries = countries.isEmpty ? [SelphIDDocumentCountry.all] : countries
            case ("documentTypes", .string(let val)):
                let types: [SelphIDDocumentType] = csvEnums(val)
                config.extractionConfiguration.documentTypes = types.isEmpty ? [.ID_CARD] : types
            case ("documentModels", .string(let val)):
                config.extractionConfiguration.documentModels = csvList(val)
            case ("generateRawImages", .bool(let val)):
                config.extractionConfiguration.generateRawImages = val
            case ("enableEncodedDataFocus", .bool(let val)):
                config.extractionConfiguration.enableEncodedDataFocus = val
            case ("videoFilename", .string(let val)):
                videoFilename = val
            case ("videoBitRate", .enumValue(let val, _)):
                videoBitRate = SelphIDVideoBitRate(rawValue: val) ?? .LOW
            case ("videoBitRateValue", .int(let val)):
                videoCustomBitRate = Int32(val)
            case ("extractorSelectionMode", .enumValue(let val, _)):
                config.extractorSelection.mode = SelphIDExtractorSelectionMode(rawValue: val) ?? .CUSTOM_ORDER
            case ("preferredVendors", .string(let val)):
                let vendors: [SelphIDExtractorVendor] = csvEnums(val)
                if !vendors.isEmpty {
                    config.extractorSelection.preferredVendors = vendors
                }
            case ("perAttemptTimeoutMs", .int(let val)):
                config.extractorSelection.perAttemptTimeoutMs = Int64(val)
            case ("timeout", .enumValue(let val, _)):
                config.timeout = (SelphIDTimeout(rawValue: val) ?? .SHORT).milliseconds
            case ("maxAttempts", .int(let val)):
                config.maxAttempts = val
            case ("vibrationEnabled", .bool(let val)):
                config.vibrationEnabled = val
            case ("debugMode", .bool(let val)):
                config.debugMode = val
            case ("orientation", .enumValue(let val, _)):
                config.orientation = SdkViewOrientation(rawValue: val) ?? .FOLLOW_SYSTEM
            case ("animateDismiss", .bool(let val)):
                config.animateDismiss = val
            default:
                break
            }
        }

        config.extractionConfiguration.captureMode = captureMode(named: captureModeName, stepSideClean: stepSideClean)
        if let filename = videoFilename.nilIfBlank {
            config.extractionConfiguration.videoRecorderConfiguration = SelphIDVideoRecorderConfiguration(
                videoFilename: filename,
                bitRate: videoBitRate,
                customBitRate: videoCustomBitRate == 0 ? nil : videoCustomBitRate
            )
        }

        return config
    }

    static func configureSelphidFields(in viewController: ConfigsComponentsVC,
                                       with selphidConfigurationData: SelphIDConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .SELPHID_COMPONENT, values: [:])
        }

        let ui = selphidConfigurationData?.uiConfiguration
        let extraction = selphidConfigurationData?.extractionConfiguration
        let selection = selphidConfigurationData?.extractorSelection
        let recorder = extraction?.videoRecorderConfiguration
        let captureMode = extraction?.captureMode ?? .FRONT

        let values: [String: ConfigValue] = [
            "showTutorial": .bool(value: ui?.showTutorial ?? true),
            "showPreviousTip": .bool(value: ui?.showPreviousTip ?? true),
            "showDiagnostic": .bool(value: ui?.showDiagnostic ?? true),
            "showAfterCapture": .bool(value: ui?.showAfterCapture ?? false),
            "showDocumentSelector": .bool(value: ui?.showDocumentSelector ?? false),
            "showTutorialOnly": .bool(value: ui?.showTutorialOnly ?? false),
            "defaultCountry": .string(value: ui?.defaultCountry ?? ""),
            "defaultDocumentType": .enumValue(
                value: (ui?.defaultDocumentType ?? .ID_CARD).rawValue,
                options: SelphIDDocumentType.allCases.map { $0.rawValue }
            ),
            "enabledCountries": .string(value: ui?.enabledCountries?.joined(separator: ", ") ?? ""),
            "enabledDocumentTypes": .string(
                value: ui?.enabledDocumentTypes?.map(\.rawValue).joined(separator: ", ") ?? ""
            ),
            "captureMode": .enumValue(
                value: captureModeName(captureMode),
                options: selphIDCaptureModeNames
            ),
            "captureModeStepSideClean": .bool(value: stepSideClean(captureMode)),
            "documentCountries": .string(value: extraction?.documentCountries.joined(separator: ", ") ?? SelphIDDocumentCountry.all),
            "documentTypes": .string(
                value: (extraction?.documentTypes ?? [.ID_CARD]).map(\.rawValue).joined(separator: ", ")
            ),
            "documentModels": .string(value: extraction?.documentModels.joined(separator: ", ") ?? ""),
            "generateRawImages": .bool(value: extraction?.generateRawImages ?? true),
            "enableEncodedDataFocus": .bool(value: extraction?.enableEncodedDataFocus ?? true),
            "videoFilename": .string(value: recorder?.videoFilename ?? ""),
            "videoBitRate": .enumValue(
                value: (recorder?.bitRate ?? .LOW).rawValue,
                options: SelphIDVideoBitRate.allCases.map { $0.rawValue }
            ),
            "videoBitRateValue": .int(value: Int(recorder?.customBitRate ?? 0)),
            "extractorSelectionMode": .enumValue(
                value: (selection?.mode ?? .CUSTOM_ORDER).rawValue,
                options: SelphIDExtractorSelectionMode.allCases.map { $0.rawValue }
            ),
            "preferredVendors": .string(
                value: (selection?.preferredVendors ?? [.EXTRACTOR_V3, .EXTRACTOR_V1]).map(\.rawValue).joined(separator: ", ")
            ),
            "perAttemptTimeoutMs": .int(value: Int(selection?.perAttemptTimeoutMs ?? 4_000)),
            "timeout": .enumValue(
                value: timeoutPreset(milliseconds: selphidConfigurationData?.timeout ?? SelphIDTimeout.SHORT.milliseconds).rawValue,
                options: SelphIDTimeout.allCases.map { $0.rawValue }
            ),
            "maxAttempts": .int(value: selphidConfigurationData?.maxAttempts ?? 3),
            "vibrationEnabled": .bool(value: selphidConfigurationData?.vibrationEnabled ?? false),
            "debugMode": .bool(value: selphidConfigurationData?.debugMode ?? false),
            "orientation": .enumValue(
                value: (selphidConfigurationData?.orientation ?? .FOLLOW_SYSTEM).rawValue,
                options: SdkViewOrientation.allCases.map { $0.rawValue }
            ),
            "animateDismiss": .bool(value: selphidConfigurationData?.animateDismiss ?? true)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView
        let switchKeys: [String] = [
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "showAfterCapture",
            "showDocumentSelector",
            "animateDismiss",
            "generateRawImages",
            "enableEncodedDataFocus",
            "showTutorialOnly",
            "debugMode",
            "captureModeStepSideClean"
        ]

        var rowStackView = UIStackView()
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
            "captureMode",
            "defaultDocumentType",
            "documentTypes",
            "enabledDocumentTypes",
            "defaultCountry",
            "documentCountries",
            "enabledCountries",
            "orientation",
            "timeout",
            "maxAttempts",
            "extractorSelectionMode",
            "preferredVendors",
            "perAttemptTimeoutMs",
            "videoFilename",
            "videoBitRate",
            "videoBitRateValue",
            "documentModels"
        ]

        for key in fieldKeys {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }

    private static func captureMode(named name: String, stepSideClean: Bool) -> SelphIDCaptureMode {
        switch name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() {
        case "STANDARD":
            return .STANDARD
        case "MRZ":
            return .MRZ
        case "STEP_SIDE":
            return .STEP_SIDE(clean: stepSideClean)
        default:
            return .FRONT
        }
    }

    private static func captureModeName(_ mode: SelphIDCaptureMode) -> String {
        switch mode {
        case .FRONT:
            return "FRONT"
        case .STANDARD:
            return "STANDARD"
        case .MRZ:
            return "MRZ"
        case .STEP_SIDE:
            return "STEP_SIDE"
        }
    }

    private static func stepSideClean(_ mode: SelphIDCaptureMode) -> Bool {
        if case .STEP_SIDE(let clean) = mode {
            return clean
        }
        return false
    }

    private static func timeoutPreset(milliseconds: Int64) -> SelphIDTimeout {
        SelphIDTimeout.allCases.first { $0.milliseconds == milliseconds } ?? .SHORT
    }

    private static func csvList(_ text: String) -> [String] {
        text.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func csvEnums<T: RawRepresentable>(_ text: String) -> [T] where T.RawValue == String {
        csvList(text).compactMap { T(rawValue: $0.uppercased()) }
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private extension Array {
    var nilIfEmpty: [Element]? {
        isEmpty ? nil : self
    }
}
