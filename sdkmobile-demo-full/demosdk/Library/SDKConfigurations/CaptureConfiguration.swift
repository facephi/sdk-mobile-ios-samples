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
    static var qrCaptureConfiguration: QrCaptureConfigurationData {
        return QrCaptureConfigurationData(
            extractionTimeout: 50000,
            cameraPreferred: .BACK,
            vibrationEnabled: true,
            showStroke: false,
            showDiagnostic: true,
            showTutorial: true,
            showPreviousTip: true
        )
    }
    
    static var qrGeneratorConfiguration: QrGeneratorConfigurationData {
        return QrGeneratorConfigurationData(source: "QR_GENERATOR_SOURCE_URL", width: 200, height: 200)
    }
    
    static var fileUploaderConfigurationData: FileUploaderConfigurationData {
        return FileUploaderConfigurationData()
    }
}

extension SdkConfigurationManager {
    static func createQrGeneratorConfigurationData(from configuration: Configuration) -> QrGeneratorConfigurationData {
        var source: String?
        var width: Int = 200
        var height: Int = 200

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("source", .string(let val)):
                source = val
            case ("width", .int(let val)):
                width = val
            case ("height", .int(let val)):
                height = val
            default:
                break
            }
        }

        return QrGeneratorConfigurationData(
            source: (source?.isEmpty == false) ? source : "QR_GENERATOR_SOURCE_URL",
            width: width,
            height: height
        )
    }

    static func configureQrGeneratorFields(in viewController: ConfigsComponentsVC,
                                           with qrGeneratorConfigurationData: QrGeneratorConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .QR_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "source": .string(value: qrGeneratorConfigurationData?.source ?? "QR_GENERATOR_SOURCE_URL"),
            "width": .int(value: qrGeneratorConfigurationData?.width ?? 200),
            "height": .int(value: qrGeneratorConfigurationData?.height ?? 200)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let fields: [String] = [
            "source",
            "width",
            "height"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}

extension SdkConfigurationManager {
    static func createFileUploaderConfigurationData(from configuration: Configuration) -> FileUploaderConfigurationData {
        var vibrationEnabled: Bool = true
        var showDiagnostic: Bool = true
        var extractionTimeout: Int = Constants.defaultExtractionTimeout
        var maxScannedDocs: Int = Constants.maxScannedDocs
        var showPreviousTip: Bool = true
        var allowGallery: Bool = true
        var onlyGalleryMode: Bool = true
        var maxGalleryImageSizeKb: Int = 2048

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
            case ("onlyGalleryMode", .bool(let val)):
                onlyGalleryMode = val
            case ("maxGalleryImageSizeKb", .int(let val)):
                maxGalleryImageSizeKb = val
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
            allowGallery: allowGallery,
            onlyGalleryMode: onlyGalleryMode,
            maxGalleryImageSizeKb: maxGalleryImageSizeKb
        )
    }

    static func configureDocumentCaptureFields(in viewController: ConfigsComponentsVC,
                                              with fileUploaderConfigurationData: FileUploaderConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .DOCUMENT_CAPTURE_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "vibrationEnabled": .bool(value: fileUploaderConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: fileUploaderConfigurationData?.showDiagnostic ?? true),
            "extractionTimeout": .int(value: fileUploaderConfigurationData?.extractionTimeout ?? Constants.defaultExtractionTimeout),
            "maxScannedDocs": .int(value: fileUploaderConfigurationData?.maxScannedDocs ?? Constants.maxScannedDocs),
            "showPreviousTip": .bool(value: fileUploaderConfigurationData?.showPreviousTip ?? true),
            "allowGallery": .bool(value: fileUploaderConfigurationData?.allowGallery ?? true),
            "onlyGalleryMode": .bool(value: fileUploaderConfigurationData?.onlyGalleryMode ?? true),
            "maxGalleryImageSizeKb": .int(value: fileUploaderConfigurationData?.maxGalleryImageSizeKb ?? 2048)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches agrupados en filas
        let switchKeys: [String] = [
            "showPreviousTip",
            "showDiagnostic",
            "vibrationEnabled",
            "allowGallery",
            "onlyGalleryMode"
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
            ("maxScannedDocs"),
            ("maxGalleryImageSizeKb")
        ]

        for (key) in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}


extension SdkConfigurationManager {
    static func createQrCaptureConfigurationData(from configuration: Configuration) -> QrCaptureConfigurationData {
        var extractionTimeout: Int = 50000
        var cameraPreferred: Camera = .BACK
        var vibrationEnabled: Bool = true
        var showStroke: Bool = false
        var showDiagnostic: Bool = true
        var showTutorial: Bool = true
        var showPreviousTip: Bool = true

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            case ("showTutorial", .bool(let val)):
                showTutorial = val
            case ("showPreviousTip", .bool(let val)):
                showPreviousTip = val
            case ("showStroke", .bool(let val)):
                showStroke = val
            case ("extractionTimeout", .int(let val)):
                extractionTimeout = val
            case ("cameraPreferred", .enumValue(let val, _)):
                cameraPreferred = Camera(rawValue: val) ?? .BACK
            default:
                break
            }
        }

        return QrCaptureConfigurationData(
            extractionTimeout: extractionTimeout,
            cameraPreferred: cameraPreferred,
            vibrationEnabled: vibrationEnabled,
            showStroke: showStroke,
            showDiagnostic: showDiagnostic,
            showTutorial: showTutorial,
            showPreviousTip: showPreviousTip
        )
    }

    static func configureQRFields(in viewController: ConfigsComponentsVC,
                                  with qrConfigurationData: QrCaptureConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .QR_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "vibrationEnabled": .bool(value: qrConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: qrConfigurationData?.showDiagnostic ?? true),
            "showTutorial": .bool(value: qrConfigurationData?.showTutorial ?? true),
            "showPreviousTip": .bool(value: qrConfigurationData?.showPreviousTip ?? true),
            "showStroke": .bool(value: qrConfigurationData?.showStroke ?? false),
            "extractionTimeout": .int(value: qrConfigurationData?.extractionTimeout ?? 50_000),
            "cameraPreferred": .enumValue(
                value: (qrConfigurationData?.cameraPreferred ?? .BACK).rawValue,
                options: Camera.allCases.map { $0.rawValue }
            )
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches agrupados en filas
        let switchKeys: [String] = [
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "showStroke"
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

        stackView.addArrangedSubview(rowStackView)

        let fields: [String] = [
            "extractionTimeout",
            "cameraPreferred"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
