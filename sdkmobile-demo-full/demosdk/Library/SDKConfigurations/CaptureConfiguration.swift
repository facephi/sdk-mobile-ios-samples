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
            cameraShape: .SQUARE,
            vibrationEnabled: true,
            showStroke: false,
            transparentBackground: false,
            showDiagnostic: true,
            showTutorial: true,
            showPreviousTip: true
        )
    }
    
    static var qrGeneratorConfiguration: QrGeneratorConfigurationData {
        return QrGeneratorConfigurationData(source: "", width: 200, height: 200)
    }
    
    static var invoiceCaptureConfiguration: InvoiceCaptureConfigurationData {
        return InvoiceCaptureConfigurationData(
            vibrationEnabled: true,
            showDiagnostic: true,
            showTutorial: true,
            timePreview: Constants.timePreview,
            previewAfterCapture: true,
            maxScannedDocs: Constants.maxScannedDocs,
            showPreviousTip: true,
            autoCapture: true
        )
    }
    
//    static var fileUploaderConfigurationData: FileUploaderConfigurationData {
//        return FileUploaderConfigurationData()
//    }
}

extension SdkConfigurationManager {
    static func createQrGeneratorConfigurationData(from configuration: Configuration) -> QrGeneratorConfigurationData {
        var source: String?
        var width: Int = 200
        var height: Int = 200
        var showDiagnostic: Bool = false

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("source", .string(let val)):
                source = val
            case ("width", .int(let val)):
                width = val
            case ("height", .int(let val)):
                height = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            default:
                break
            }
        }

        return QrGeneratorConfigurationData(
            source: source,
            width: width,
            height: height,
            showDiagnostic: showDiagnostic
        )
    }

    static func configureQrGeneratorFields(in viewController: ConfigsComponentsVC,
                                           with qrGeneratorConfigurationData: QrGeneratorConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .QR_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "source": .string(value: qrGeneratorConfigurationData?.source ?? ""),
            "width": .int(value: qrGeneratorConfigurationData?.width ?? 200),
            "height": .int(value: qrGeneratorConfigurationData?.height ?? 200),
            "showDiagnostic": .bool(value: qrGeneratorConfigurationData?.showDiagnostic ?? false)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches agrupados en filas
        let switchKeys: [String] = [
            "showDiagnostic"
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
    static func createInvoiceCaptureConfigurationData(from configuration: Configuration) -> InvoiceCaptureConfigurationData {
        var vibrationEnabled: Bool = true
        var showDiagnostic: Bool = true
        var showTutorial: Bool = true
        var timePreview: Int = Constants.timePreview
        var previewAfterCapture: Bool = true
        var maxScannedDocs: Int = Constants.maxScannedDocs
        var showPreviousTip: Bool = true
        var autoCapture: Bool = false

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            case ("showTutorial", .bool(let val)):
                showTutorial = val
            case ("timePreview", .int(let val)):
                timePreview = val
            case ("previewAfterCapture", .bool(let val)):
                previewAfterCapture = val
            case ("maxScannedDocs", .int(let val)):
                maxScannedDocs = val
            case ("showPreviousTip", .bool(let val)):
                showPreviousTip = val
            case ("autoCapture", .bool(let val)):
                autoCapture = val
            default:
                break
            }
        }

        return InvoiceCaptureConfigurationData(
            vibrationEnabled: vibrationEnabled,
            showDiagnostic: showDiagnostic,
            showTutorial: showTutorial,
            timePreview: timePreview,
            previewAfterCapture: previewAfterCapture,
            maxScannedDocs: maxScannedDocs,
            showPreviousTip: showPreviousTip,
            autoCapture: autoCapture
        )
    }
    
//    static func createFileUploaderConfigurationData(from configuration: Configuration) -> FileUploaderConfigurationData {
//        var vibrationEnabled: Bool = true
//        var showDiagnostic: Bool = true
//        var extractionTimeout: Int = Constants.defaultExtractionTimeout
//        var maxScannedDocs: Int = Constants.maxScannedDocs
//        var showPreviousTip: Bool = true
//        var allowGallery: Bool = true
//
//        for (key, value) in configuration.values {
//            switch (key, value) {
//            case ("vibrationEnabled", .bool(let val)):
//                vibrationEnabled = val
//            case ("showDiagnostic", .bool(let val)):
//                showDiagnostic = val
//            case ("extractionTimeout", .int(let val)):
//                extractionTimeout = val
//            case ("maxScannedDocs", .int(let val)):
//                maxScannedDocs = val
//            case ("showPreviousTip", .bool(let val)):
//                showPreviousTip = val
//            case ("allowGallery", .bool(let val)):
//                allowGallery = val
//            default:
//                break
//            }
//        }
//        
//        return FileUploaderConfigurationData(
//            extractionTimeout: extractionTimeout,
//            vibrationEnabled: vibrationEnabled,
//            showDiagnostic: showDiagnostic,
//            showPreviousTip: showPreviousTip,
//            maxScannedDocs: maxScannedDocs,
//            allowGallery: allowGallery
//        )
//    }

    static func configureInvoiceCaptureFields(in viewController: ConfigsComponentsVC,
                                              with invoiceConfigurationData: InvoiceCaptureConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .CAPTURE_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "vibrationEnabled": .bool(value: invoiceConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: invoiceConfigurationData?.showDiagnostic ?? true),
            "showTutorial": .bool(value: invoiceConfigurationData?.showTutorial ?? true),
            "timePreview": .int(value: invoiceConfigurationData?.timePreview ?? Constants.timePreview),
            "previewAfterCapture": .bool(value: invoiceConfigurationData?.previewAfterCapture ?? true),
            "maxScannedDocs": .int(value: invoiceConfigurationData?.maxScannedDocs ?? Constants.maxScannedDocs),
            "showPreviousTip": .bool(value: invoiceConfigurationData?.showPreviousTip ?? true),
            "autoCapture": .bool(value: invoiceConfigurationData?.autoCapture ?? true)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches agrupados en filas
        let switchKeys: [String] = [
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "previewAfterCapture",
            "autoCapture"
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
            ("timePreview"),
            ("maxScannedDocs")
        ]

        for (key) in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
    
//    static func configureDocumentCaptureFields(in viewController: ConfigsComponentsVC,
//                                              with fileUploaderConfigurationData: FileUploaderConfigurationData?) {
//        if viewController.configuration == nil {
//            viewController.configuration = Configuration(configType: .DOCUMENT_CAPTURE_COMPONENT, values: [:])
//        }
//
//        let values: [String: ConfigValue] = [
//            "vibrationEnabled": .bool(value: fileUploaderConfigurationData?.vibrationEnabled ?? true),
//            "showDiagnostic": .bool(value: fileUploaderConfigurationData?.showDiagnostic ?? true),
//            "extractionTimeout": .int(value: fileUploaderConfigurationData?.extractionTimeout ?? Constants.defaultExtractionTimeout),
//            "maxScannedDocs": .int(value: fileUploaderConfigurationData?.maxScannedDocs ?? Constants.maxScannedDocs),
//            "showPreviousTip": .bool(value: fileUploaderConfigurationData?.showPreviousTip ?? true),
//            "allowGallery": .bool(value: fileUploaderConfigurationData?.allowGallery ?? true)
//        ]
//
//        viewController.configuration!.values.merge(values) { (_, new) in new }
//
//        let stackView = viewController.stackView
//
//        // Crear switches agrupados en filas
//        let switchKeys: [String] = [
//            "showPreviousTip",
//            "showDiagnostic",
//            "vibrationEnabled",
//            "allowGallery"
//        ]
//
//        var rowStackView: UIStackView = UIStackView()
//        rowStackView.axis = .horizontal
//        rowStackView.alignment = .fill
//        rowStackView.distribution = .fillEqually
//        rowStackView.spacing = 16
//
//        for (index, key) in switchKeys.enumerated() {
//            if let value = viewController.configuration!.values[key] {
//                let switchField = viewController.createField(key: key, value: value)
//                rowStackView.addArrangedSubview(switchField)
//
//                // Cuando la fila alcanza 2 elementos o es el último elemento, agrégala al stackView
//                if (index + 1) % 2 == 0 || index == switchKeys.count - 1 {
//                    stackView.addArrangedSubview(rowStackView)
//                    
//                    // Crear una nueva fila solo si no es el último elemento
//                    if index != switchKeys.count - 1 {
//                        rowStackView = UIStackView()
//                        rowStackView.axis = .horizontal
//                        rowStackView.alignment = .fill
//                        rowStackView.distribution = .fillEqually
//                        rowStackView.spacing = 16
//                    }
//                }
//            }
//        }
//
//        stackView.addArrangedSubview(rowStackView)
//
//        // Agregar los campos generados con `createField`
//        let fields: [String] = [
//            ("extractionTimeout"),
//            ("maxScannedDocs")
//        ]
//
//        for (key) in fields {
//            if let value = viewController.configuration!.values[key] {
//                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
//            }
//        }
//    }
}


extension SdkConfigurationManager {
    static func createQrCaptureConfigurationData(from configuration: Configuration) -> QrCaptureConfigurationData {
        var extractionTimeout: Int = 50000
        var cameraPreferred: Camera = .BACK
        var cameraShape: CameraShape = .SQUARE
        var vibrationEnabled: Bool = true
        var showStroke: Bool = false
        var transparentBackground: Bool = false
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
            case ("transparentBackground", .bool(let val)):
                transparentBackground = val
            case ("extractionTimeout", .int(let val)):
                extractionTimeout = val
            case ("cameraPreferred", .enumValue(let val, _)):
                cameraPreferred = Camera(rawValue: val) ?? .BACK
            case ("cameraShape", .enumValue(let val, _)):
                cameraShape = CameraShape(rawValue: val) ?? .SQUARE
            default:
                break
            }
        }

        return QrCaptureConfigurationData(
            extractionTimeout: extractionTimeout,
            cameraPreferred: cameraPreferred,
            cameraShape: cameraShape,
            vibrationEnabled: vibrationEnabled,
            showStroke: showStroke,
            transparentBackground: transparentBackground,
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
            "transparentBackground": .bool(value: qrConfigurationData?.transparentBackground ?? false),
            "extractionTimeout": .int(value: qrConfigurationData?.extractionTimeout ?? 10000),
            "cameraPreferred": .enumValue(
                value: (qrConfigurationData?.cameraPreferred ?? .FRONT).rawValue,
                options: Camera.allCases.map { $0.rawValue }
            ),
            "cameraShape": .enumValue(
                value: (qrConfigurationData?.cameraShape ?? .SQUARE).rawValue,
                options: CameraShape.allCases.map { $0.rawValue }
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
            "showStroke",
            "transparentBackground"
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
            "cameraPreferred",
            "cameraShape"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}

extension SdkConfigurationManager {
    static func createGalleryConfigurationData(from configuration: Configuration) -> PhotoFromGalleryConfigurationData {
        var vibrationEnabled: Bool? = true
        var showDiagnostic: Bool? = true
        var previewAfterAdd: Bool? = true
        var maxScannedDocs: Int? = 5

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            case ("previewAfterAdd", .bool(let val)):
                previewAfterAdd = val
            case ("maxScannedDocs", .int(let val)):
                maxScannedDocs = val
            default:
                break
            }
        }

        return PhotoFromGalleryConfigurationData(
            vibrationEnabled: vibrationEnabled ?? true,
            showDiagnostic: showDiagnostic ?? true,
            previewAfterAdd: previewAfterAdd ?? true
        )
    }

    static func configureGalleryFields(in viewController: ConfigsComponentsVC,
                                              with photoFromGalleryConfigurationData: PhotoFromGalleryConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .CAPTURE_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "vibrationEnabled": .bool(value: photoFromGalleryConfigurationData?.vibrationEnabled ?? true),
            "showDiagnostic": .bool(value: photoFromGalleryConfigurationData?.showDiagnostic ?? true),
            "previewAfterAdd": .bool(value: photoFromGalleryConfigurationData?.previewAfterAdd ?? true)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches agrupados en filas
        let switchKeys: [String] = [
            "vibrationEnabled",
            "previewAfterAdd",
            "showDiagnostic"
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
            ("maxScannedDocs")
        ]

        for (key) in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
