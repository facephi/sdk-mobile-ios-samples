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
    static var videoCallConfiguration: VideoCallConfigurationData {
        VideoCallConfigurationData(
            vibrationEnabled: true,
            activateScreenSharing: false,
            timeout: 60_000
        )
    }
}

extension SdkConfigurationManager {
    static func createVideoCallConfigurationData(from configuration: Configuration) -> VideoCallConfigurationData {
        var activateScreenSharing: Bool?
        var vibrationEnabled: Bool?
        var url: String?
        var apiKey: String?
        var tenantId: String?
        var timeout: Int?
        var debug: Bool?
        var customerId: String?
        var email: String?

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
            case ("debug", .bool(let val)):
                debug = val
            case ("customerId", .string(let val)):
                customerId = val.isEmpty ? nil : val
            case ("email", .string(let val)):
                email = val.isEmpty ? nil : val
            default:
                break
            }
        }

        return VideoCallConfigurationData(
            url: url?.isEmpty == false ? url : nil,
            apiKey: apiKey?.isEmpty == false ? apiKey : nil,
            tenantId: tenantId?.isEmpty == false ? tenantId : nil,
            vibrationEnabled: vibrationEnabled ?? true,
            activateScreenSharing: activateScreenSharing ?? false,
            timeout: timeout ?? 60_000,
            debug: debug ?? false,
            customerId: customerId,
            email: email
        )
    }

    static func configureVideoCallFields(in viewController: ConfigsComponentsVC,
                                         with videoCallConfigurationData: VideoCallConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .VIDEOCALL_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "activateScreenSharing": .bool(value: videoCallConfigurationData?.activateScreenSharing ?? false),
            "vibrationEnabled": .bool(value: videoCallConfigurationData?.vibrationEnabled ?? true),
            "debug": .bool(value: videoCallConfigurationData?.debug ?? false),
            "url": .string(value: videoCallConfigurationData?.url ?? ""),
            "apiKey": .string(value: videoCallConfigurationData?.apiKey ?? ""),
            "tenantId": .string(value: videoCallConfigurationData?.tenantId ?? ""),
            "customerId": .string(value: videoCallConfigurationData?.customerId ?? ""),
            "email": .string(value: videoCallConfigurationData?.email ?? ""),
            "timeout": .int(value: videoCallConfigurationData?.timeout ?? 60_000)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "activateScreenSharing",
            "vibrationEnabled",
            "debug"
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
            "url",
            "apiKey",
            "tenantId",
            "customerId",
            "email",
            "timeout"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
