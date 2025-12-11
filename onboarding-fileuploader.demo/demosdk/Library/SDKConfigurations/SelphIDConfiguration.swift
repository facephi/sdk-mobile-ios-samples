//
//  SelphIDConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphidComponent
import UIKit

extension SdkConfigurationManager {
    static func createSelphidConfigurationData(from configuration: Configuration) -> SelphIDConfigurationData {
        var config = SelphIDConfigurationData()

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("resourcesPath", .string(let val)):
                config.resourcesPath = selphidResources(resource: val)
            case ("wizardMode", .bool(let val)):
                config.wizardMode = val
            case ("showResultAfterCapture", .bool(let val)):
                config.showResultAfterCapture = val
            case ("showTutorial", .bool(let val)):
                config.showTutorial = val
            case ("scanMode", .enumValue(let val, _)):
                config.scanMode = SelphIDScanMode(rawValue: val) ?? .MODE_SEARCH
            case ("specificData", .string(let val)):
                config.specificData = val
            case ("documentType", .enumValue(let val, _)):
                config.documentType = SelphIDDocumentType(rawValue: val) ?? .ID_CARD
            case ("showDiagnostic", .bool(let val)):
                config.showDiagnostic = val
            case ("showPreviousTip", .bool(let val)):
                config.showPreviousTip = val
            case ("debug", .bool(let val)):
                config.debug = val
            case ("tokenImageQuality", .float(let val)):
                config.tokenImageQuality = val
            case ("documentSide", .enumValue(let val, _)):
                config.documentSide = SelphIDDocumentSide(rawValue: val) ?? .FRONT
            case ("timeout", .enumValue(let val, _)):
                config.timeout = SelphIDTimeout(rawValue: val) ?? .MEDIUM
            case ("generateRawImages", .bool(let val)):
                config.generateRawImages = val
            case ("videoFilename", .string(let val)):
                config.videoFilename = val
            case ("tokenPreviousCaptureData", .string(let val)):
                config.tokenPreviousCaptureData = val
            case ("vibrationEnabled", .bool(let val)):
                config.vibrationEnabled = val
            default:
                break
            }
        }
        return config
    }
    
    static func selphidResources(resource: String) -> String? {
        let resourcesSelphid: String = {
            let selphidZipName = resource
            return Bundle.main.path(
                forResource: selphidZipName,
                ofType: "zip") ?? ""
        }()
        
        return resourcesSelphid
    }

    static func configureSelphidFields(in viewController: ConfigsComponentsVC,
                                       with selphidConfigurationData: SelphIDConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .SELPHID_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "resourcesPath": .string(value: selphidConfigurationData?.resourcesPath ?? "fphi-selphid-widget-resources-sdk"),
            "wizardMode": .bool(value: selphidConfigurationData?.wizardMode ?? true),
            "showResultAfterCapture": .bool(value: selphidConfigurationData?.showResultAfterCapture ?? true),
            "showTutorial": .bool(value: selphidConfigurationData?.showTutorial ?? true),
            "scanMode": .enumValue(
                value: (selphidConfigurationData?.scanMode ?? .MODE_SEARCH).rawValue,
                options: SelphIDScanMode.allCases.map { $0.rawValue }
            ),
            "specificData": .string(value: selphidConfigurationData?.specificData ?? "ES|<ALL>"),
            "documentType": .enumValue(
                value: (selphidConfigurationData?.documentType ?? .ID_CARD).rawValue,
                options: SelphIDDocumentType.allCases.map { $0.rawValue }
            ),
            "showDiagnostic": .bool(value: selphidConfigurationData?.showDiagnostic ?? true),
            "showPreviousTip": .bool(value: selphidConfigurationData?.showPreviousTip ?? true),
            "debug": .bool(value: selphidConfigurationData?.debug ?? false),
            "tokenImageQuality": .float(value: selphidConfigurationData?.tokenImageQuality ?? 0.8),
            "documentSide": .enumValue(
                value: (selphidConfigurationData?.documentSide ?? .FRONT).rawValue,
                options: SelphIDDocumentSide.allCases.map { $0.rawValue }
            ),
            "timeout": .enumValue(
                value: (selphidConfigurationData?.timeout ?? .MEDIUM).rawValue,
                options: SelphIDTimeout.allCases.map { $0.rawValue }
            ),
            "generateRawImages": .bool(value: selphidConfigurationData?.generateRawImages ?? true),
            "vibrationEnabled": .bool(value: selphidConfigurationData?.vibrationEnabled ?? true),
            "videoFilename": .string(value: selphidConfigurationData?.videoFilename ?? ""),
            "tokenPreviousCaptureData": .string(value: selphidConfigurationData?.tokenPreviousCaptureData ?? "")
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "showResultAfterCapture",
            "wizardMode",
            "debug",
            "generateRawImages"
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
        
        let fieldKeys: [String] = [
            "resourcesPath",
            "scanMode",
            "documentType",
            "documentSide",
            "timeout",
            "specificData",
            "tokenImageQuality",
            "locale",
            "videoFilename",
            "tokenPreviousCaptureData"
        ]

        for key in fieldKeys {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}

