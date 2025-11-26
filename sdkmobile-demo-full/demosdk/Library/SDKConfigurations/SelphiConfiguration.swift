//
//  SelphiConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphiComponent
import UIKit

extension SdkConfigurationManager {
    static var selphiConfiguration: SelphiConfigurationData {
        var configSelphi = SelphiConfigurationData()
        
        let resourcesSelphi: String = {
            let selphiZipName = "fphi-selphi-widget-resources-sdk"
            return Bundle.main.path(
                forResource: selphiZipName,
                ofType: "zip") ?? ""
        }()
        
        configSelphi.debug = false
        configSelphi.livenessMode = SelphiFaceLivenessMode.PASSIVE
        configSelphi.stabilizationMode = false
        configSelphi.templateRawOptimized = true
        configSelphi.qrMode = false
        configSelphi.resourcesPath = resourcesSelphi
        configSelphi.showTutorial = true
        configSelphi.showPreviousTip = true
        configSelphi.cameraPreferred = .FRONT
        configSelphi.moveSuccessfulAttempts = 1
        configSelphi.moveFailedAttempts = 3
        
        return configSelphi
    }
}

extension SdkConfigurationManager {
    // swiftlint:disable all
    static func createSelphiConfigurationData(from configuration: Configuration) -> SelphiConfigurationData {
        var config = SelphiConfigurationData()
        
        for (key, value) in configuration.values {
            switch (key, value) {
            case ("resourcesPath", .string(let val)):
                config.resourcesPath = selphiResources(resource: val)
            case ("showTutorial", .bool(let val)):
                config.showTutorial = val
            case ("showDiagnostic", .bool(let val)):
                config.showDiagnostic = val
            case ("showResultAfterCapture", .bool(let val)):
                config.showResultAfterCapture = val
            case ("showPreviousTip", .bool(let val)):
                config.showPreviousTip = val
            case ("livenessMode", .enumValue(let val, _)):
                config.livenessMode = SelphiFaceLivenessMode(rawValue: val)
            case ("debug", .bool(let val)):
                config.debug = val
            case ("stabilizationMode", .bool(let val)):
                config.stabilizationMode = val
            case ("templateRawOptimized", .bool(let val)):
                config.templateRawOptimized = val
            case ("qrMode", .bool(let val)):
                config.qrMode = val
            case ("videoFilename", .string(let val)):
                config.videoFilename = val
            case ("cameraFlashEnabled", .bool(let val)):
                config.cameraFlashEnabled = val
            case ("cameraPreferred", .enumValue(let val, _)):
                config.cameraPreferred = SelphiCamera(rawValue: val)
            case ("moveSuccessfulAttempts", .int(let val)):
                config.moveSuccessfulAttempts = val
            case ("moveFailedAttempts", .int(let val)):
                config.moveFailedAttempts = val
            case ("logImages", .bool(let val)):
                config.logImages = val
            case ("translationsContent", .string(let val)):
                config.translationsContent = val
            case ("viewsContent", .string(let val)):
                config.viewsContent = val
            case ("vibrationEnabled", .bool(let val)):
                config.vibrationEnabled = val
            default:
                break
            }
        }
        return config
    }

    static func selphiResources(resource: String) -> String? {
        let resourcesSelphi: String = {
            let selphiZipName = resource
            return Bundle.main.path(
                forResource: selphiZipName,
                ofType: "zip") ?? ""
        }()
        
        return resourcesSelphi
    }
    
    static func configureSelphiFields(in viewController: ConfigsComponentsVC, with selphiConfigurationData: SelphiConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .SELPHI_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "resourcesPath": .string(value: selphiConfigurationData?.resourcesPath ?? "fphi-selphi-widget-resources-sdk"),
            "showTutorial": .bool(value: selphiConfigurationData?.showTutorial ?? true),
            "showDiagnostic": .bool(value: selphiConfigurationData?.showDiagnostic ?? true),
            "showResultAfterCapture": .bool(value: selphiConfigurationData?.showResultAfterCapture ?? true),
            "showPreviousTip": .bool(value: selphiConfigurationData?.showPreviousTip ?? true),
            "livenessMode": .enumValue(
                value: (selphiConfigurationData?.livenessMode ?? .PASSIVE).rawValue,
                options: SelphiFaceLivenessMode.allCases.map { $0.rawValue }
            ),
            "debug": .bool(value: selphiConfigurationData?.debug ?? false),
            "stabilizationMode": .bool(value: selphiConfigurationData?.stabilizationMode ?? true),
            "templateRawOptimized": .bool(value: selphiConfigurationData?.templateRawOptimized ?? true),
            "qrMode": .bool(value: selphiConfigurationData?.qrMode ?? false),
            "videoFilename": .string(value: selphiConfigurationData?.videoFilename ?? ""),
            "cameraFlashEnabled": .bool(value: selphiConfigurationData?.cameraFlashEnabled ?? true),
            "cameraPreferred": .enumValue(
                value: (selphiConfigurationData?.cameraPreferred ?? .FRONT).rawValue,
                options: SelphiCamera.allCases.map { $0.rawValue }
            ),
            "moveSuccessfulAttempts": .int(value: selphiConfigurationData?.moveSuccessfulAttempts ?? 1),
            "moveFailedAttempts": .int(value: selphiConfigurationData?.moveFailedAttempts ?? 2),
            "logImages": .bool(value: selphiConfigurationData?.logImages ?? false),
            "translationsContent": .string(value: selphiConfigurationData?.translationsContent ?? ""),
            "viewsContent": .string(value: selphiConfigurationData?.viewsContent ?? ""),
            "vibrationEnabled": .bool(value: selphiConfigurationData?.vibrationEnabled ?? true)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "showResultAfterCapture",
            "debug",
            "qrMode",
            "stabilizationMode",
            "cameraFlashEnabled",
            "templateRawOptimized",
            "logImages"
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
            "livenessMode",
            "cameraPreferred",
            "resourcesPath",
            "locale",
            "videoFilename",
            "cameraId",
            "moveSuccessfulAttempts",
            "moveFailedAttempts"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
