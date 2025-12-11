//
//  CaptureConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 3/10/24.
//

import Foundation
import UIKit
import captureComponent

extension SdkConfigurationManager {
    static func createFileUploaderConfigurationData(from configuration: Configuration) -> FileUploaderConfigurationData {
        var vibrationEnabled: Bool = true
        var showDiagnostic: Bool = true
        var extractionTimeout: Int = Constants.defaultExtractionTimeout
        var maxScannedDocs: Int = Constants.maxScannedDocs
        var showPreviousTip: Bool = true
        var allowGallery: Bool = true

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            case ("extractionTimeout", .int(let val)):
                extractionTimeout = val
            case ("maxScannedDocs", .int(let val)):
                maxScannedDocs = val
            case ("showPreviousTip", .bool(let val)):
                showPreviousTip = val
            case ("allowGallery", .bool(let val)):
                allowGallery = val
            default:
                break
            }
        }
        
        return FileUploaderConfigurationData(
            extractionTimeout: extractionTimeout,
            vibrationEnabled: vibrationEnabled,
            showDiagnostic: showDiagnostic,
            showPreviousTip: showPreviousTip,
            maxScannedDocs: maxScannedDocs,
            allowGallery: allowGallery
        )
    }

    static func configureFileUploaderFields(in viewController: ConfigsComponentsVC,
                                              with fileUploaderConfigurationData: FileUploaderConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .FILE_UPLOADER_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "vibrationEnabled": .bool(value: fileUploaderConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: fileUploaderConfigurationData?.showDiagnostic ?? true),
            "extractionTimeout": .int(value: fileUploaderConfigurationData?.extractionTimeout ?? Constants.defaultExtractionTimeout),
            "maxScannedDocs": .int(value: fileUploaderConfigurationData?.maxScannedDocs ?? Constants.maxScannedDocs),
            "showPreviousTip": .bool(value: fileUploaderConfigurationData?.showPreviousTip ?? true),
            "allowGallery": .bool(value: fileUploaderConfigurationData?.allowGallery ?? true)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches agrupados en filas
        let switchKeys: [String] = [
            "showPreviousTip",
            "showDiagnostic",
            "vibrationEnabled",
            "allowGallery"
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

        stackView.addArrangedSubview(rowStackView)

        // Agregar los campos generados con `createField`
        let fields: [String] = [
            ("extractionTimeout"),
            ("maxScannedDocs")
        ]

        for (key) in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
