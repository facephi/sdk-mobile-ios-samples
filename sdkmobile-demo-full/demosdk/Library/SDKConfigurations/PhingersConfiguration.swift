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
        configPhingers.fingerSelectorHandOrientation = .LEFT
        configPhingers.videoRecordingEnabled = true
        configPhingers.videoRecordingQuality = .MEDIUM
        
        return configPhingers
    }
}

extension SdkConfigurationManager {
    static func createPhingersConfigurationData(from configuration: Configuration) -> PhingersConfigurationData {
        var config = PhingersConfigurationData()
        
        var fingerSelectorOptions: [FingerFilter] = []
        
        for (key, value) in configuration.values {
            switch (key, value) {
            case ("useDemoKmpCustomCameraOverlay", .bool(let val)):
                SdkConfigurationManager.useDemoKmpCustomCameraOverlay = val
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
                config.reticleOrientation = ReticleOrientation(rawValue: val)
            case("showEllipses", .bool(let val)):
                config.showEllipses = val
            case("enableFlash", .bool(let val)):
                config.enableFlash = val
            case("showTutorial", .bool(let val)):
                config.showTutorial = val
            case("detectorThreshold", .float(let val)):
                config.detectorThreshold = val
            case("livenessThreshold", .float(let val)):
                config.livenessThreshold = val
            case("useLiveness", .bool(let val)):
                config.useLiveness = val
            case("templateType", .enumValue(let val, _)):
                config.templateType = TemplateType(rawValue: val)
            case("showPreviousFingerSelector", .bool(let val)):
                config.showPreviousFingerSelector = val
            case("extractionTimeout", .int(let val)):
                config.extractionTimeout = val
            case("fingerSelectorHandOrientation", .enumValue(let val, _)):
                config.fingerSelectorHandOrientation = CaptureOrientation(rawValue: val)
            case("videoRecordingEnabled", .bool(let val)):
                config.videoRecordingEnabled = val
            case("videoRecordingDirectoryPath", .string(let val)):
                config.videoRecordingDirectoryPath = val.nilIfEmpty
            case("videoRecordingFileName", .string(let val)):
                config.videoRecordingFileName = val.nilIfEmpty
            case("videoRecordingQuality", .enumValue(let val, _)):
                config.videoRecordingQuality = VideoRecordingQuality(rawValue: val)
            case("indexFinger", .bool(let val)):
                if val { fingerSelectorOptions.append(.INDEX_FINGER) }
            case("middleFinger", .bool(let val)):
                if val { fingerSelectorOptions.append(.MIDDLE_FINGER) }
            case("ringFinger", .bool(let val)):
                if val { fingerSelectorOptions.append(.RING_FINGER) }
            case("littleFinger", .bool(let val)):
                if val { fingerSelectorOptions.append(.LITTLE_FINGER) }
            case("thumbFinger", .bool(let val)):
                if val { fingerSelectorOptions.append(.THUMB_FINGER) }
            case("slap", .bool(let val)):
                if val { fingerSelectorOptions.append(.SLAP) }
            case("all4OneByOne", .bool(let val)):
                if val { fingerSelectorOptions.append(.ALL_4_FINGERS_ONE_BY_ONE) }
            case("all5OneByOne", .bool(let val)):
                if val { fingerSelectorOptions.append(.ALL_5_FINGERS_ONE_BY_ONE) }
            default :
                break
            }
            
            if !fingerSelectorOptions.isEmpty {
                fingerSelectorOptions.sort { $0.rawValue < $1.rawValue }
                config.fingerSelectorOptions = fingerSelectorOptions
            }
        }
        return config
    }
    
    static func configurePhingersFields(in viewController: ConfigsComponentsVC, with phingersConfigurationData: PhingersConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .PHINGER_COMPONENT, values: [:])
        }
        
        let values: [String: ConfigValue] = [
            "useDemoKmpCustomCameraOverlay": .bool(value: SdkConfigurationManager.useDemoKmpCustomCameraOverlay),
            "vibrationEnabled": .bool(value: phingersConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: phingersConfigurationData?.showDiagnostic ?? true),
            "fingerFilter": .enumValue(
                value: (phingersConfigurationData?.fingerFilter ?? .SLAP).rawValue,
                options: FingerFilter.allCases.map { $0.rawValue }
            ),
            "cropHeight": .int(value: phingersConfigurationData?.cropHeight ?? Int()),
            "cropWidth": .int(value: phingersConfigurationData?.cropWidth ?? Int()),
            "showPreviousTip": .bool(value: phingersConfigurationData?.showPreviousTip ?? true),
            "extractionTimeout": .int(value: phingersConfigurationData?.extractionTimeout ?? 50000),
            "reticleOrientation": .enumValue(
                value: (phingersConfigurationData?.reticleOrientation ?? .LEFT).rawValue,
                options: ReticleOrientation.allCases.map { $0.rawValue }
            ),
            "showEllipses": .bool(value: phingersConfigurationData?.showEllipses ?? true),
            "enableFlash": .bool(value: phingersConfigurationData?.enableFlash ?? true),
            "showTutorial": .bool(value: phingersConfigurationData?.showTutorial ?? true),
            "detectorThreshold": .float(value: phingersConfigurationData?.detectorThreshold ?? Float()),
            "livenessThreshold": .float(value: phingersConfigurationData?.livenessThreshold ?? Float()),
            "useLiveness": .bool(value: phingersConfigurationData?.useLiveness ?? true),
            "templateType": .enumValue(
                value: (phingersConfigurationData?.templateType ?? .NIST_TEMPLATE).rawValue,
                options: TemplateType.allCases.map { $0.rawValue }
            ),
            "showPreviousFingerSelector": .bool(value: phingersConfigurationData?.showPreviousFingerSelector ?? true),
            "indexFinger": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .INDEX_FINGER }) ?? true),
            "middleFinger": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .MIDDLE_FINGER }) ?? true),
            "ringFinger": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .RING_FINGER }) ?? true),
            "littleFinger": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .LITTLE_FINGER }) ?? true),
            "thumbFinger": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .THUMB_FINGER }) ?? true),
            "slap": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .SLAP }) ?? true),
            "all4OneByOne": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .ALL_4_FINGERS_ONE_BY_ONE }) ?? true),
            "all5OneByOne": .bool(value: phingersConfigurationData?.fingerSelectorOptions?.contains(where: { $0 == .ALL_5_FINGERS_ONE_BY_ONE }) ?? true),
            "fingerSelectorHandOrientation": .enumValue(
                value: (phingersConfigurationData?.fingerSelectorHandOrientation ?? .LEFT).rawValue,
                options: CaptureOrientation.allCases.map { $0.rawValue }
            ),
            "videoRecordingEnabled": .bool(value: phingersConfigurationData?.videoRecordingEnabled ?? true),
            "videoRecordingDirectoryPath": .string(value: phingersConfigurationData?.videoRecordingDirectoryPath ?? ""),
            "videoRecordingFileName": .string(value: phingersConfigurationData?.videoRecordingFileName ?? ""),
            "videoRecordingQuality": .enumValue(
                value: (phingersConfigurationData?.videoRecordingQuality ?? .MEDIUM).rawValue,
                options: VideoRecordingQuality.allCases.map { $0.rawValue }
            ),
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "useDemoKmpCustomCameraOverlay",
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "showEllipses",
            "enableFlash",
            "useLiveness",
            "showPreviousFingerSelector",
            "videoRecordingEnabled",
            "indexFinger",
            "middleFinger",
            "ringFinger",
            "littleFinger",
            "thumbFinger",
            "slap",
            "all4OneByOne",
            "all5OneByOne"
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
            "templateType",
            "fingerSelectorHandOrientation",
            "videoRecordingQuality",
            "extractionTimeout",
            "cropWidth",
            "cropHeight",
            "detectorThreshold",
            "livenessThreshold"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }

        let stringFields: [String] = [
            "videoRecordingDirectoryPath",
            "videoRecordingFileName"
        ]

        for key in stringFields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : self
    }
}
