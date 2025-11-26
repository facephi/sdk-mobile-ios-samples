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
        
        let configVoiceID = VoiceConfigurationData(
            phrases: PrefManager.get(String.self, forKey: .KEY_VOICE_ID_PHRASES)?.components(separatedBy: ",") ?? ["Facephi Biometria"],
            showTutorial: PrefManager.get(Bool.self, forKey: .KEY_VOICE_ID_SHOW_TUTORIAL) ?? true)
        return configVoiceID
    }
}

extension SdkConfigurationManager {
    static func createVoiceIDConfigurationData(from configuration: Configuration) -> VoiceConfigurationData {
        var phrases: [String] = []
        var showTutorial: Bool? = true
        var vibrationEnabled: Bool? = true
        var showDiagnostic: Bool? = true
        var showPreviousTip: Bool? = true
        var extractionTimeout: Int? = 5000
        var enableQualityCheck: Bool? = true

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
            default:
                break
            }
        }

        return VoiceConfigurationData(
            phrases: phrases.count == 0 ? ["Facephi Biometria"] : phrases,
            showTutorial: showTutorial ?? true,
            extractionTimeout: extractionTimeout ?? 5000,
            showDiagnostic: showDiagnostic ?? true,
            vibrationEnabled: vibrationEnabled ?? true,
            enableQualityCheck: enableQualityCheck ?? true,
            showPreviousTip: showPreviousTip ?? true
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
            "extractionTimeout": .int(value: voiceIDConfigurationData?.extractionTimeout ?? 5000),
            "enableQualityCheck": .bool(value: voiceIDConfigurationData?.enableQualityCheck ?? true)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches agrupados en filas
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

                // Cuando la fila alcanza 2 elementos o es el último elemento, agrégala al stackView
                if (index + 1) % 2 == 0 || index == switchKeys.count - 1 {
                    stackView.addArrangedSubview(rowStackView)
                    
                    // Crear una nueva fila solo si no es el último elemento
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

        // Agregar los campos generados con `createField`
        let fields: [String] = [
            "phrases",
            "minSpeechLength",
            "extractionTimeout"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }

}
