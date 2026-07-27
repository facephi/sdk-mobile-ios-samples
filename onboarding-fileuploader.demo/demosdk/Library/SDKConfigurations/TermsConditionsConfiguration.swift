//
//  TermsConditionsConfiguration.swift
//  demosdk
//
//  Created by Codex on 13/7/26.
//

import Foundation
import termsConditionsComponent

extension SdkConfigurationManager {
    private static let defaultTermsConditionsText = """
    <h4>GENERAL DATA PROTECTION REGULATION</h4>
    <p>Accepting this session implies acceptance of data processing for demo purposes.</p>
    """

    static func createTermsConditionsConfigurationData(from configuration: Configuration) -> TermsConditionsConfigurationData {
        var termsConditions: String = defaultTermsConditionsText
        var extractionTimeout: Int64 = Int64(Constants.defaultExtractionTimeout)
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

        return TermsConditionsConfigurationData(
            termsConditions: termsConditions,
            extractionTimeout: extractionTimeout,
            orientation: orientation
        )
    }

    static func configureTermsConditionsFields(in viewController: ConfigsComponentsVC,
                                               with termsConditionsConfigurationData: TermsConditionsConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .TERMS_CONDITIONS_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "termsConditions": .string(value: termsConditionsConfigurationData?.termsConditions ?? defaultTermsConditionsText),
            "extractionTimeout": .int(value: Int(termsConditionsConfigurationData?.extractionTimeout ?? Int64(Constants.defaultExtractionTimeout))),
            "orientation": .enumValue(
                value: termsConditionsConfigurationData?.orientation?.rawValue ?? TermsConditionsSdkOrientation.followSystem.rawValue,
                options: termsConditionsOrientationOptions()
            )
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let fields: [String] = [
            "termsConditions",
            "extractionTimeout",
            "orientation"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                viewController.stackView.addArrangedSubview(viewController.createField(key: key, value: value))
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
