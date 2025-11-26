//
//  VideoCallConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videocallComponent
import Foundation
import UIKit

extension SdkConfigurationManager {
    static var videoCallConfiguration: VideoCallConfigurationData{
        var configVideoCall = VideoCallConfigurationData(vibrationEnabled: true,
                                                         activateScreenSharing: true,
                                                         timeout: 8000)        
        return configVideoCall
    }
}

extension SdkConfigurationManager {
    static func createVideoCallConfigurationData(from configuration: Configuration) -> VideoCallConfigurationData {
        var activateScreenSharing: Bool? = false
        var vibrationEnabled: Bool? = true
        var url: String?
        var apiKey: String?
        var tenantId: String?
        var timeout: Int? = 60000

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("activateScreenSharing", .bool(let val)):
                activateScreenSharing = val
            case ("vibrationEnabled", .bool(let val)):
                vibrationEnabled = val
            case ("url", .string(let val)):
                url = val
            case ("apiKey", .string(let val)):
                apiKey = val
            case ("tenantId", .string(let val)):
                tenantId = val
            case ("timeout", .int(let val)):
                timeout = val
            default:
                break
            }
        }

        return VideoCallConfigurationData(
            url: url == "" ? nil : url,
            apiKey: apiKey == "" ? nil : apiKey,
            tenantId: tenantId == "" ? nil : tenantId,
            vibrationEnabled: vibrationEnabled ?? true,
            activateScreenSharing: activateScreenSharing ?? false,
            timeout: timeout ?? 60000
        )
    }

    static func configureVideoCallFields(in viewController: ConfigsComponentsVC,
                                         with videoCallConfigurationData: VideoCallConfigurationData?) {
        // Asegurar que `configuration` está inicializado
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .VIDEOCALL_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "activateScreenSharing": .bool(value: videoCallConfigurationData?.activateScreenSharing ?? true),
            "vibrationEnabled": .bool(value: videoCallConfigurationData?.vibrationEnabled ?? true),
            "url": .string(value: videoCallConfigurationData?.url ?? ""),
            "apiKey": .string(value: videoCallConfigurationData?.apiKey ?? ""),
            "tenantId": .string(value: videoCallConfigurationData?.tenantId ?? ""),
            "timeout": .int(value: videoCallConfigurationData?.timeout ?? 6000)
        ]

        // Modificar directamente la configuración en `viewController`
        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Crear switches en una fila horizontal
        let switchKeys: [String] = [
            "activateScreenSharing",
            "vibrationEnabled"
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
            "tenantId",
            "timeout"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}

