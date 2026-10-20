//
//  VideoRecordingConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 3/10/24.
//

import Foundation
import UIKit
import videoRecordingComponent

extension SdkConfigurationManager {
    static func createVideoRecordingConfigurationData(from configuration: Configuration) -> VideoRecordingConfigurationData {
        var enableAudio: Bool = true
        var showDiagnostic: Bool = true
        var url: String?
        var apiKey: String?
        var tenantId: String?

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("enableAudio", .bool(let val)):
                enableAudio = val
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            case ("url", .string(let val)):
                url = val
            case ("apiKey", .string(let val)):
                apiKey = val
            case ("tenantId", .string(let val)):
                tenantId = val
            default:
                break
            }
        }

        return VideoRecordingConfigurationData(
            url: url == "" ? nil : url,
            apiKey: apiKey == "" ? nil : apiKey,
            tenantId: tenantId == "" ? nil : tenantId,
            showDiagnostic: showDiagnostic,
            enableAudio: enableAudio
        )
    }
    
    static func configureVideoRecordingDataFields(in viewController: ConfigsComponentsVC,
                                              with videoRecordingConfigurationData: VideoRecordingConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .START_VIDEO_RECORDING_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "enableAudio": .bool(value: videoRecordingConfigurationData?.enableAudio ?? true),
            "showDiagnostic": .bool(value: videoRecordingConfigurationData?.showDiagnostic ?? true),
            "url": .string(value: videoRecordingConfigurationData?.url ?? ""),
            "apiKey": .string(value: videoRecordingConfigurationData?.apiKey ?? ""),
            "tenantId": .string(value: videoRecordingConfigurationData?.tenantId ?? "")
        ]

        // Modificar directamente la configuración en `viewController`
        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches en una fila horizontal
        let switchKeys: [String] = [
            "enableAudio",
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
            "url",
            "apiKey",
            "tenantId"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
