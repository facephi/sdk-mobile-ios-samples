//
//  VideoIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videoidComponent
import Foundation
import UIKit

extension SdkConfigurationManager {
    static var videoIDConfiguration: VideoIDConfigurationData {
        return VideoIDConfigurationData(showCompletedTutorial: true)
    }
}

extension SdkConfigurationManager {
    static func createVideoIDConfigurationData(from configuration: Configuration) -> VideoIDConfigurationData {
        
        var showCompletedTutorial: Bool?
        var mode: VideoIdMode?
        var cameraPreferred: VideoIdCamera?
        var vibrationEnabled: Bool?
        var url: String?
        var apiKey: String?
        var tenantId: String?
        var timeoutServerConnection: Int?
        var sectionTime: Int?
        var sectionTimeout: Int?
        var autoFaceDetection: Bool?
        var documentQualityThreshold: Double?

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("showCompletedTutorial", .bool(let val)):
                showCompletedTutorial = val
            case ("cameraPreferred", .enumValue(let val, _)):
                cameraPreferred = VideoIdCamera(rawValue: val)
            case ("mode", .enumValue(let val, _)):
                mode = VideoIdMode(rawValue: val)
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("url", .string(let val)):
                url = val
            case ("apiKey", .string(let val)):
                apiKey = val
            case ("tenantId", .string(let val)):
                tenantId = val
            case ("timeoutServerConnection", .int(let val)):
                timeoutServerConnection = val
            case ("sectionTime", .int(let val)):
                sectionTime = val
            case ("sectionTimeout", .int(let val)):
                sectionTimeout = val
            case ("autoFaceDetection", .bool(let val)):
                autoFaceDetection = val
            case ("documentQualityThreshold", .double(let val)):
                documentQualityThreshold = val
            default:
                break
            }
        }

        return VideoIDConfigurationData(
            sectionTime: sectionTime ?? 3000,
            mode: mode ?? .FACE_DOCUMENT_FRONT_BACK,
            url: url == "" ? nil : url,
            apiKey: apiKey == "" ? nil : apiKey,
            tenantId: tenantId == "" ? nil : tenantId,
            showCompletedTutorial: showCompletedTutorial ?? true,
            vibrationEnabled: vibrationEnabled ?? true,
            timeoutServerConnection: timeoutServerConnection ?? 15000,
            sectionTimeout: sectionTimeout ?? 10000,
            cameraPreferred: cameraPreferred ?? .FRONT,
            autoFaceDetection: autoFaceDetection ?? true,
            documentQualityThreshold: documentQualityThreshold ?? 0.7
        )
    }

    static func configureVideoIDFields(in viewController: ConfigsComponentsVC,
                                       with videoIDConfigurationData: VideoIDConfigurationData?) {
        // Asegurar que `configuration` está inicializado
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .VIDEOID_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "sectionTime": .int(value: videoIDConfigurationData?.sectionTime ?? 3000),
            "mode": .enumValue(
                value: (videoIDConfigurationData?.mode ?? .FACE_DOCUMENT_FRONT_BACK).rawValue,
                options: VideoIdMode.allCases.map { $0.rawValue }
            ),
            "url": .string(value: videoIDConfigurationData?.url ?? ""),
            "apiKey": .string(value: videoIDConfigurationData?.apiKey ?? ""),
            "tenantId": .string(value: videoIDConfigurationData?.tenantId ?? ""),
            "showCompletedTutorial": .bool(value: videoIDConfigurationData?.showCompletedTutorial ?? true),
            "vibrationEnabled": .bool(value: videoIDConfigurationData?.vibrationEnabled ?? false),
            "timeoutServerConnection": .int(value: videoIDConfigurationData?.timeoutServerConnection ?? 15000),
            "sectionTimeout": .int(value: videoIDConfigurationData?.sectionTimeout ?? 10000),
            "cameraPreferred": .enumValue(
                value: (videoIDConfigurationData?.cameraPreferred ?? .FRONT).rawValue,
                options: VideoIdCamera.allCases.map { $0.rawValue }
            ),
            "autoFaceDetection": .bool(value: videoIDConfigurationData?.autoFaceDetection ?? true),
            "documentQualityThreshold": .double(value: videoIDConfigurationData?.documentQualityThreshold ?? 0.7)
        ]

        // Modificar directamente la configuración en viewController
        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView
        
        // Crear switches en una fila horizontal
        let switchKeys: [String] = [
            "showCompletedTutorial",
            "vibrationEnabled",
            "autoFaceDetection"
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

        // Agregar los campos generados con `createField`
        let fields: [String] = [
            "sectionTime",
            "mode",
            "documentQualityThreshold",
            "url",
            "apiKey",
            "tenantId",
            "timeoutServerConnection",
            "sectionTimeout",
            "timeoutFaceDetection",
            "cameraPreferred"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
