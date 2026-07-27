//
//  TermsConditionsConfiguration.swift
//  demosdk
//
//  Created by Codex on 2026-07-02.
//

import Foundation
import termsConditionsComponent

extension SdkConfigurationManager {
    static func createTermsConditionsConfigurationData(from configuration: Configuration) -> TermsConditionsConfigurationData {
        var termsConditions: String = ""
        var extractionTimeout: Int64 = 60000
        var orientation: TermsConditionsSdkOrientation = .followSystem

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("termsConditions", .string(let val)):
                termsConditions = val
            case ("extractionTimeout", .int(let val)):
                extractionTimeout = Int64(val)
            case ("orientation", .enumValue(let val, _)):
                orientation = termsConditionsOrientation(from: val)
            default:
                break
            }
        }

        let payload: [String: Any] = [
            "termsConditions": termsConditions,
            "extractionTimeout": extractionTimeout,
            "orientation": orientation.rawValue
        ]

        let data = try! JSONSerialization.data(withJSONObject: payload, options: [])
        return try! JSONDecoder().decode(TermsConditionsConfigurationData.self, from: data)
    }

    static func configureTermsConditionsFields(in viewController: ConfigsComponentsVC,
                                               with termsConditionsConfigurationData: TermsConditionsConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .TERMS_CONDITIONS_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "termsConditions": .string(value: termsConditionsConfigurationData?.termsConditions ?? """
    <h4>GENERAL DATA PROTECTION REGULATION</h4>
    <p>Accepting this session implies acceptance of data processing for demo purposes.</p>
    """),
            "extractionTimeout": .int(value: Int(termsConditionsConfigurationData?.extractionTimeout ?? 60000)),
            "orientation": .enumValue(
                value: termsConditionsConfigurationData?.orientation?.rawValue ?? TermsConditionsSdkOrientation.followSystem.rawValue,
                options: termsConditionsOrientationOptions()
            )
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView
        let fields: [String] = [
            "termsConditions",
            "extractionTimeout",
            "orientation"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }

    private static func termsConditionsOrientationOptions() -> [String] {
        return [
            TermsConditionsSdkOrientation.followSystem.rawValue,
            TermsConditionsSdkOrientation.portrait.rawValue,
            TermsConditionsSdkOrientation.landscape.rawValue
        ]
    }

    private static func termsConditionsOrientation(from name: String) -> TermsConditionsSdkOrientation {
        switch name {
        case TermsConditionsSdkOrientation.portrait.rawValue:
            return .portrait
        case TermsConditionsSdkOrientation.landscape.rawValue:
            return .landscape
        default:
            return .followSystem
        }
    }
}
