//
//  VoiceIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import voiceIDComponent
import Foundation
import UIKit

extension SdkConfigurationManager {
    static var voiceIDConfiguration: VoiceConfigurationData {
        VoiceConfigurationData(
            phrases: PrefManager.get(String.self, forKey: .KEY_VOICE_ID_PHRASES)?.components(separatedBy: ",") ?? ["Facephi Biometria"],
            showTutorial: PrefManager.get(Bool.self, forKey: .KEY_VOICE_ID_SHOW_TUTORIAL) ?? true
        )
    }
}

extension SdkConfigurationManager {
    static func createVoiceIDConfigurationData(from configuration: Configuration) -> VoiceConfigurationData {
        var phrases: [String] = []
        var showTutorial: Bool?
        var vibrationEnabled: Bool?
        var showDiagnostic: Bool?
        var showPreviousTip: Bool?
        var extractionTimeout: Int?
        var enableQualityCheck: Bool?
        var maxAttempts: Int?

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("phrases", .string(let val)):
                phrases = val.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            case ("showTutorial", .bool(let val)):
                showTutorial = val
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            case ("showPreviousTip", .bool(let val)):
                showPreviousTip = val
            case ("extractionTimeout", .int(let val)):
                extractionTimeout = val
            case ("enableQualityCheck", .bool(let val)):
                enableQualityCheck = val
            case ("maxAttempts", .int(let val)):
                maxAttempts = val
            default:
                break
            }
        }

        return VoiceConfigurationData(
            phrases: phrases.isEmpty ? ["Facephi Biometria"] : phrases,
            showTutorial: showTutorial ?? true,
            extractionTimeout: extractionTimeout ?? 50_000,
            showDiagnostic: showDiagnostic ?? true,
            vibrationEnabled: vibrationEnabled ?? true,
            enableQualityCheck: enableQualityCheck ?? true,
            showPreviousTip: showPreviousTip ?? true,
            maxAttempts: maxAttempts ?? 3
        )
    }

    static func configureVoiceIDFields(in viewController: ConfigsComponentsVC,
                                       with voiceIDConfigurationData: VoiceConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .VOICE_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "phrases": .string(value: voiceIDConfigurationData?.phrases.joined(separator: ", ") ?? "Facephi Biometria"),
            "showTutorial": .bool(value: voiceIDConfigurationData?.showTutorial ?? true),
            "vibrationEnabled": .bool(value: voiceIDConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: voiceIDConfigurationData?.showDiagnostic ?? true),
            "showPreviousTip": .bool(value: voiceIDConfigurationData?.showPreviousTip ?? true),
            "extractionTimeout": .int(value: voiceIDConfigurationData?.extractionTimeout ?? 50_000),
            "enableQualityCheck": .bool(value: voiceIDConfigurationData?.enableQualityCheck ?? true),
            "maxAttempts": .int(value: voiceIDConfigurationData?.maxAttempts ?? 3)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "enableQualityCheck"
        ]

        var rowStackView: UIStackView = UIStackView()
        rowStackView.axis = .horizontal
        rowStackView.alignment = .fill
        rowStackView.distribution = .fillEqually
        rowStackView.spacing = 16

        for (index, key) in switchKeys.enumerated() {
            if let value = viewController.configuration!.values[key] {
                let switchField = viewController.createField(key: key, value: value)
                rowStackView.addArrangedSubview(switchField)

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

        let fields: [String] = [
            "phrases",
            "extractionTimeout",
            "maxAttempts"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
