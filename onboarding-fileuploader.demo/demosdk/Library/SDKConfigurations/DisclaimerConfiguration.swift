//
//  DisclaimerConfiguration.swift
//  demosdk
//
//  Created by Codex on 13/7/26.
//

import Foundation
import disclaimerComponent

extension SdkConfigurationManager {
    private static let defaultDisclaimerText = """
    <h4>GENERAL DATA PROTECTION REGULATION</h4>
    <p>Accepting this session implies acceptance of data processing for demo purposes.</p>
    """

    static func createDisclaimerConfigurationData(from configuration: Configuration) -> DisclaimerConfigurationData {
        var disclaimerText: String = defaultDisclaimerText
        var extractionTimeout: Int = Constants.defaultExtractionTimeout
        var orientation: DisclaimerSdkOrientation = .followSystem

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("disclaimerText", .string(let val)):
                disclaimerText = val
            case ("extractionTimeout", .int(let val)):
                extractionTimeout = val
            case ("orientation", .enumValue(let val, _)):
                orientation = disclaimerOrientation(from: val)
            default:
                break
            }
        }

        return DisclaimerConfigurationData(
            disclaimerText: disclaimerText,
            extractionTimeout: extractionTimeout,
            orientation: orientation
        )
    }

    static func configureDisclaimerFields(in viewController: ConfigsComponentsVC,
                                          with disclaimerConfigurationData: DisclaimerConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .DISCLAIMER_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "disclaimerText": .string(value: disclaimerConfigurationData?.disclaimerText ?? defaultDisclaimerText),
            "extractionTimeout": .int(value: disclaimerConfigurationData?.extractionTimeout ?? Constants.defaultExtractionTimeout),
            "orientation": .enumValue(
                value: disclaimerConfigurationData?.orientation?.rawValue ?? DisclaimerSdkOrientation.followSystem.rawValue,
                options: disclaimerOrientationOptions()
            )
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let fields: [String] = [
            "disclaimerText",
            "extractionTimeout",
            "orientation"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                viewController.stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }

    private static func disclaimerOrientationOptions() -> [String] {
        return [
            DisclaimerSdkOrientation.followSystem.rawValue,
            DisclaimerSdkOrientation.portrait.rawValue,
            DisclaimerSdkOrientation.landscape.rawValue
        ]
    }

    private static func disclaimerOrientation(from name: String) -> DisclaimerSdkOrientation {
        switch name {
        case DisclaimerSdkOrientation.portrait.rawValue:
            return .portrait
        case DisclaimerSdkOrientation.landscape.rawValue:
            return .landscape
        default:
            return .followSystem
        }
    }
}
