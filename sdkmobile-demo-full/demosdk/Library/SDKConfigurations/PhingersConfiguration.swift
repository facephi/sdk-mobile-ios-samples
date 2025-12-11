//
//  PhingersConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import UIKit
import phingersTFComponent

extension SdkConfigurationManager {
    static var phingersConfiguration: PhingersConfigurationData {
        var configPhingers = PhingersConfigurationData()
        
        configPhingers.showTutorial = true
        configPhingers.reticleOrientation = .LEFT
        configPhingers.templateType = .NIST_TEMPLATE
        
        return configPhingers
    }
}

extension SdkConfigurationManager {
    static func createPhingersConfigurationData(from configuration: Configuration) -> PhingersConfigurationData {
                
        var config = PhingersConfigurationData()
        
        for (key, value) in configuration.values {
            switch (key, value) {
            case("vibrationEnabled",.bool(let val)):
                config.vibrationEnabled = val
            case("showDiagnostic", .bool(let val)):
                config.showDiagnostic = val
            case("fingerFilter", .enumValue(let val, _)):
                config.fingerFilter = FingerFilter(rawValue: val)
            case("cropHeight", .int(let val)):
                config.cropHeight = val
            case("cropWidth", .int(let val)):
                config.cropWidth = val
            case("showPreviousTip", .bool(let val)):
                config.showPreviousTip = val
            case("reticleOrientation", .enumValue(let val, _)):
                config.reticleOrientation = CaptureOrientation(rawValue: val)
            case("showEllipses", .bool(let val)):
                config.showEllipses = val
            case("showTutorial", .bool(let val)):
                config.showTutorial = val
            case("threshold", .float(let val)):
                config.threshold = val
            case("useLiveness", .bool(let val)):
                config.useLiveness = val
            case("templateType", .enumValue(let val, _)):
                config.templateType = TemplateType(rawValue: val)
            default :
                break
            }
        }
        return config
    }
    
    static func configurePhingersFields(in viewController: ConfigsComponentsVC, with phingersConfigurationData: PhingersConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .PHINGER_COMPONENT, values: [:])
        }
        
        let values: [String: ConfigValue] = [
            
            "vibrationEnabled": .bool(value: phingersConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: phingersConfigurationData?.showDiagnostic ?? true),
            "fingerFilter": .enumValue(
                value: (phingersConfigurationData?.fingerFilter ?? .SLAP).rawValue,
                options: FingerFilter.allCases.map { $0.rawValue }
            ),
            "cropHeight": .int(value: phingersConfigurationData?.cropHeight ?? Int()),
            "cropWidth": .int(value: phingersConfigurationData?.cropHeight ?? Int()),
            "showPreviousTip": .bool(value: phingersConfigurationData?.showPreviousTip ?? true),
            "extractionTimeout": .int(value: phingersConfigurationData?.extractionTimeout ?? 50000),
            "reticleOrientation": .enumValue(
                value: (phingersConfigurationData?.reticleOrientation ?? .LEFT).rawValue,
                options: CaptureOrientation.allCases.map { $0.rawValue }
            ),
            "showEllipses": .bool(value: phingersConfigurationData?.showEllipses ?? true),
            "showTutorial": .bool(value: phingersConfigurationData?.showTutorial ?? true),
            "threshold": .float(value: phingersConfigurationData?.threshold ?? Float()),
            "useLiveness": .bool(value: phingersConfigurationData?.useLiveness ?? true),
            "templateType": .enumValue(
                value: (phingersConfigurationData?.templateType ?? .NIST_TEMPLATE).rawValue,
                options: TemplateType.allCases.map { $0.rawValue }
            )
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "cropHeight",
            "cropWidth",
            "extractionTimeout",
            "showEllipses",
            "threshold",
            "useLiveness"
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
            "fingerFilter",
            "reticleOrientation",
            "templateType"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
