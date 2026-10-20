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
        VideoIDConfigurationData(showCompletedTutorial: true)
    }

    private static func parseCommaSeparatedList(_ value: String) -> [String]? {
        let items = value
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        return items.isEmpty ? nil : items
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
        var maxRetries: Int?
        var documentQualityThreshold: Double?
        var countryFilter: [String]?
        var documentFilter: [String]?
        var speechText: String?
        var debug: Bool?
        var enableAudio: Bool?
        var ocrMaxWarnings: Int?
        var customerId: String?
        var documentReaderMode: VideoIdDocumentReaderMode?
        var modelFilter: [String]?
        var showDiagnostic: Bool?

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
            case ("maxRetries", .int(let val)):
                maxRetries = val
            case ("documentQualityThreshold", .double(let val)):
                documentQualityThreshold = val
            case ("countryFilter", .string(let val)):
                countryFilter = parseCommaSeparatedList(val)
            case ("documentFilter", .string(let val)):
                documentFilter = parseCommaSeparatedList(val)
            case ("speechText", .string(let val)):
                speechText = val.isEmpty ? nil : val
            case ("debug", .bool(let val)):
                debug = val
            case ("enableAudio", .bool(let val)):
                enableAudio = val
            case ("ocrMaxWarnings", .int(let val)):
                ocrMaxWarnings = val
            case ("customerId", .string(let val)):
                customerId = val.isEmpty ? nil : val
            case ("documentReaderMode", .enumValue(let val, _)):
                documentReaderMode = VideoIdDocumentReaderMode(rawValue: val)
            case ("modelFilter", .string(let val)):
                modelFilter = parseCommaSeparatedList(val)
            case ("showDiagnostic", .bool(let val)):
                showDiagnostic = val
            default:
                break
            }
        }

        return VideoIDConfigurationData(
            sectionTime: sectionTime ?? 5_000,
            mode: mode ?? .FACE_DOCUMENT_FRONT_BACK,
            url: url?.isEmpty == false ? url : nil,
            apiKey: apiKey?.isEmpty == false ? apiKey : nil,
            tenantId: tenantId?.isEmpty == false ? tenantId : nil,
            showCompletedTutorial: showCompletedTutorial ?? true,
            vibrationEnabled: vibrationEnabled ?? true,
            timeoutServerConnection: timeoutServerConnection ?? 15_000,
            sectionTimeout: sectionTimeout ?? 15_000,
            cameraPreferred: cameraPreferred ?? .FRONT,
            autoFaceDetection: autoFaceDetection ?? true,
            maxRetries: maxRetries ?? 3,
            documentQualityThreshold: documentQualityThreshold ?? 0.7,
            countryFilter: countryFilter,
            documentFilter: documentFilter,
            speechText: speechText,
            debug: debug ?? false,
            enableAudio: enableAudio ?? true,
            ocrMaxWarnings: ocrMaxWarnings ?? 5,
            customerId: customerId,
            documentReaderMode: documentReaderMode,
            modelFilter: modelFilter,
            showDiagnostic: showDiagnostic
        )
    }

    static func configureVideoIDFields(in viewController: ConfigsComponentsVC,
                                       with videoIDConfigurationData: VideoIDConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .VIDEOID_COMPONENT, values: [:])
        }

        let values: [String: ConfigValue] = [
            "sectionTime": .int(value: videoIDConfigurationData?.sectionTime ?? 5_000),
            "mode": .enumValue(
                value: (videoIDConfigurationData?.mode ?? .FACE_DOCUMENT_FRONT_BACK).rawValue,
                options: VideoIdMode.allCases.map { $0.rawValue }
            ),
            "url": .string(value: videoIDConfigurationData?.url ?? ""),
            "apiKey": .string(value: videoIDConfigurationData?.apiKey ?? ""),
            "tenantId": .string(value: videoIDConfigurationData?.tenantId ?? ""),
            "showCompletedTutorial": .bool(value: videoIDConfigurationData?.showCompletedTutorial ?? true),
            "vibrationEnabled": .bool(value: videoIDConfigurationData?.vibrationEnabled ?? true),
            "timeoutServerConnection": .int(value: videoIDConfigurationData?.timeoutServerConnection ?? 15_000),
            "sectionTimeout": .int(value: videoIDConfigurationData?.sectionTimeout ?? 15_000),
            "cameraPreferred": .enumValue(
                value: (videoIDConfigurationData?.cameraPreferred ?? .FRONT).rawValue,
                options: VideoIdCamera.allCases.map { $0.rawValue }
            ),
            "autoFaceDetection": .bool(value: videoIDConfigurationData?.autoFaceDetection ?? true),
            "maxRetries": .int(value: videoIDConfigurationData?.maxRetries ?? 3),
            "documentQualityThreshold": .double(value: videoIDConfigurationData?.documentQualityThreshold ?? 0.7),
            "countryFilter": .string(value: videoIDConfigurationData?.countryFilter?.joined(separator: ", ") ?? ""),
            "documentFilter": .string(value: videoIDConfigurationData?.documentFilter?.joined(separator: ", ") ?? ""),
            "speechText": .string(value: videoIDConfigurationData?.speechText ?? ""),
            "debug": .bool(value: videoIDConfigurationData?.debug ?? false),
            "enableAudio": .bool(value: videoIDConfigurationData?.enableAudio ?? true),
            "ocrMaxWarnings": .int(value: videoIDConfigurationData?.ocrMaxWarnings ?? 5),
            "customerId": .string(value: videoIDConfigurationData?.customerId ?? ""),
            "documentReaderMode": .enumValue(
                value: (videoIDConfigurationData?.documentReaderMode ?? .DOCUMENT_MODE).rawValue,
                options: VideoIdDocumentReaderMode.allCases.map { $0.rawValue }
            ),
            "modelFilter": .string(value: videoIDConfigurationData?.modelFilter?.joined(separator: ", ") ?? ""),
            "showDiagnostic": .bool(value: videoIDConfigurationData?.showDiagnostic ?? true)
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "showCompletedTutorial",
            "vibrationEnabled",
            "autoFaceDetection",
            "debug",
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
            "sectionTime",
            "sectionTimeout",
            "mode",
            "documentReaderMode",
            "cameraPreferred",
            "documentQualityThreshold",
            "maxRetries",
            "ocrMaxWarnings",
            "url",
            "apiKey",
            "tenantId",
            "customerId",
            "timeoutServerConnection",
            "countryFilter",
            "documentFilter",
            "modelFilter",
            "speechText"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
