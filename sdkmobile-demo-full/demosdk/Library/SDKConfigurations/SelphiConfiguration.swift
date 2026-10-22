//
//  SelphiConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphiComponent
import UIKit
import core

extension SdkConfigurationManager {
    static var selphiConfiguration: SelphiConfigurationData {
        var configSelphi = SelphiConfigurationData()

        configSelphi.livenessMode = .LIVENESS_PASSIVE
        configSelphi.qrConfiguration.enableQrReader = false
        configSelphi.facialConfiguration.selphiCameraConfiguration.showTutorial = true
        configSelphi.facialConfiguration.selphiCameraConfiguration.showPreviousTip = true
        configSelphi.facialConfiguration.selphiCameraConfiguration.cameraPreferred = .FRONT

        return configSelphi
    }
}

extension SdkConfigurationManager {
    // swiftlint:disable all
    static func createSelphiConfigurationData(from configuration: Configuration) -> SelphiConfigurationData {
        var config = SelphiConfigurationData()
        var moveSuccessfulAttempts = 1
        var moveFailedAttempts = 2
        var clearVideoRecorder = false

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("useDemoKmpCustomCameraOverlay", .bool(let val)):
                SdkConfigurationManager.useDemoKmpCustomCameraOverlay = val
            case ("showTutorial", .bool(let val)):
                config.facialConfiguration.selphiCameraConfiguration.showTutorial = val
            case ("showDiagnostic", .bool(let val)):
                config.facialConfiguration.selphiCameraConfiguration.showDiagnostic = val
            case ("showResultAfterCapture", .bool(let val)):
                config.facialConfiguration.showAfterCapture = val
            case ("showPreviousTip", .bool(let val)):
                config.facialConfiguration.selphiCameraConfiguration.showPreviousTip = val
            case ("livenessMode", .enumValue(let val, _)):
                config.livenessMode = SelphiFaceLivenessMode.fromLegacyName(
                    val,
                    successfulAttempts: moveSuccessfulAttempts,
                    failedAttempts: moveFailedAttempts
                )
            case ("qrMode", .bool(let val)):
                config.qrConfiguration.enableQrReader = val
            case ("qrTimeoutMs", .int(let val)):
                config.qrConfiguration.timeout = Int64(val)
            case ("videoFilename", .string(let val)):
                if val.isEmpty {
                    clearVideoRecorder = true
                    config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration = nil
                } else {
                    clearVideoRecorder = false
                    var recorder = config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration
                        ?? SelphiVideoRecorderConfiguration()
                    recorder.videoFilename = val
                    config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration = recorder
                }
            case ("cameraPreferred", .enumValue(let val, _)):
                if let camera = SelphiCamera(rawValue: val) {
                    config.facialConfiguration.selphiCameraConfiguration.cameraPreferred = camera
                }
            case ("cameraShape", .enumValue(let val, _)):
                if let shape = SelphiCameraShape(rawValue: val) {
                    config.facialConfiguration.selphiCameraConfiguration.cameraShape = shape
                }
            case ("qrCameraShape", .enumValue(let val, _)):
                if let shape = SelphiCameraShape(rawValue: val) {
                    config.qrConfiguration.qrCameraConfiguration.cameraShape = shape
                }
            case ("moveSuccessfulAttempts", .int(let val)):
                moveSuccessfulAttempts = val
                if case .LIVENESS_MOVE(_, let failedAttempts) = config.livenessMode {
                    config.livenessMode = .LIVENESS_MOVE(
                        successfulAttempts: val,
                        failedAttempts: failedAttempts
                    )
                }
            case ("moveFailedAttempts", .int(let val)):
                moveFailedAttempts = val
                if case .LIVENESS_MOVE(let successfulAttempts, _) = config.livenessMode {
                    config.livenessMode = .LIVENESS_MOVE(
                        successfulAttempts: successfulAttempts,
                        failedAttempts: val
                    )
                }
            case ("maxAttempts", .int(let val)):
                config.maxAttempts = val
            case ("vibrationEnabled", .bool(let val)):
                config.vibrationEnabled = val
            case ("extractionDuration", .enumValue(let val, _)):
                config.facialConfiguration.extractionConfiguration.extractionTime = SelphiExtractionDuration(rawValue: val)
            case ("extractionProgressMode", .enumValue(let val, _)):
                if let progressMode = SelphiExtractionProgressMode(rawValue: val) {
                    config.facialConfiguration.extractionConfiguration.progressMode = progressMode
                }
            case ("videoBitRate", .enumValue(let val, _)):
                if let bitRate = SelphiVideoBitRate(rawValue: val) {
                    var recorder = config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration
                        ?? SelphiVideoRecorderConfiguration()
                    recorder.bitRate = bitRate
                    config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration = recorder
                }
            case ("videoBitRateValue", .int(let val)):
                var recorder = config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration
                    ?? SelphiVideoRecorderConfiguration()
                recorder.customBitRate = Int32(val)
                config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration = recorder
            case ("iadEnabled", .bool(let val)):
                config.iadConfiguration.enabled = val
            case ("iadPayloadSize", .enumValue(let val, _)):
                if let payloadSize = SelphiIadPayloadSize(rawValue: val) {
                    config.iadConfiguration.payloadSize = payloadSize
                }
            case ("iadBundleTimeoutMs", .int(let val)):
                if val > 0 {
                    config.iadConfiguration.bundleTimeoutMs = Int64(val)
                }
            case ("params", .string(let val)):
                config.facialConfiguration.extractionConfiguration.parameters = parseSelphiParams(val)
            case ("widgetParams", .string(let val)):
                config.params = parseSelphiParams(val)
            default:
                break
            }
        }

        if clearVideoRecorder {
            config.facialConfiguration.extractionConfiguration.videoRecorderConfiguration = nil
        }

        return config
    }

    private static let selphiLivenessModeNames = [
        "LIVENESS_PASSIVE",
        "LIVENESS_NONE",
        "LIVENESS_NONE_STABILIZED",
        "LIVENESS_MOVE"
    ]

    private static func moveAttempts(from mode: SelphiFaceLivenessMode?) -> (successful: Int, failed: Int) {
        if case .LIVENESS_MOVE(let successfulAttempts, let failedAttempts) = mode {
            return (successfulAttempts, failedAttempts)
        }
        return (1, 2)
    }

    private static func parseSelphiParams(_ text: String) -> [String: String]? {
        let lines = text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        guard !lines.isEmpty else { return nil }

        var params: [String: String] = [:]
        for line in lines {
            let parts = line.split(separator: "=", maxSplits: 1).map(String.init)
            guard parts.count == 2 else { continue }
            params[parts[0].trimmingCharacters(in: .whitespaces)] = parts[1].trimmingCharacters(in: .whitespaces)
        }
        return params.isEmpty ? nil : params
    }

    static func configureSelphiFields(in viewController: ConfigsComponentsVC, with selphiConfigurationData: SelphiConfigurationData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .SELPHI_COMPONENT, values: [:])
        }

        let camera = selphiConfigurationData?.facialConfiguration.selphiCameraConfiguration
        let extraction = selphiConfigurationData?.facialConfiguration.extractionConfiguration
        let qrCamera = selphiConfigurationData?.qrConfiguration.qrCameraConfiguration
        let recorder = extraction?.videoRecorderConfiguration
        let moveAttempts = Self.moveAttempts(from: selphiConfigurationData?.livenessMode)
        let params = extraction?.parameters
        let widgetParams = selphiConfigurationData?.params

        let values: [String: ConfigValue] = [
            "useDemoKmpCustomCameraOverlay": .bool(value: SdkConfigurationManager.useDemoKmpCustomCameraOverlay),
            "showTutorial": .bool(value: camera?.showTutorial ?? true),
            "showDiagnostic": .bool(value: camera?.showDiagnostic ?? true),
            "showResultAfterCapture": .bool(value: selphiConfigurationData?.facialConfiguration.showAfterCapture ?? true),
            "showPreviousTip": .bool(value: camera?.showPreviousTip ?? true),
            "livenessMode": .enumValue(
                value: selphiConfigurationData?.livenessMode?.flowName ?? "LIVENESS_PASSIVE",
                options: selphiLivenessModeNames
            ),
            "qrMode": .bool(value: selphiConfigurationData?.qrConfiguration.enableQrReader ?? false),
            "qrTimeoutMs": .int(value: Int(selphiConfigurationData?.qrConfiguration.timeout ?? 30_000)),
            "videoFilename": .string(value: recorder?.videoFilename ?? ""),
            "cameraPreferred": .enumValue(
                value: (camera?.cameraPreferred ?? .FRONT).rawValue,
                options: SelphiCamera.allCases.map { $0.rawValue }
            ),
            "cameraShape": .enumValue(
                value: (camera?.cameraShape ?? .CIRCULAR).rawValue,
                options: SelphiCameraShape.allCases.map { $0.rawValue }
            ),
            "qrCameraShape": .enumValue(
                value: (qrCamera?.cameraShape ?? .CIRCULAR).rawValue,
                options: SelphiCameraShape.allCases.map { $0.rawValue }
            ),
            "moveSuccessfulAttempts": .int(value: moveAttempts.successful),
            "moveFailedAttempts": .int(value: moveAttempts.failed),
            "maxAttempts": .int(value: selphiConfigurationData?.maxAttempts ?? 3),
            "vibrationEnabled": .bool(value: selphiConfigurationData?.vibrationEnabled ?? false),
            "extractionDuration": .enumValue(
                value: (extraction?.extractionTime ?? .SHORT).rawValue,
                options: SelphiExtractionDuration.allCases.map { $0.rawValue }
            ),
            "extractionProgressMode": .enumValue(
                value: (extraction?.progressMode ?? .PAUSE_AND_RESUME_ON_ERROR).rawValue,
                options: SelphiExtractionProgressMode.allCases.map { $0.rawValue }
            ),
            "videoBitRate": .enumValue(
                value: (recorder?.bitRate ?? .LOW).rawValue,
                options: SelphiVideoBitRate.allCases.map { $0.rawValue }
            ),
            "videoBitRateValue": .int(value: Int(recorder?.customBitRate ?? 0)),
            "iadEnabled": .bool(value: selphiConfigurationData?.iadConfiguration.enabled ?? false),
            "iadPayloadSize": .enumValue(
                value: (selphiConfigurationData?.iadConfiguration.payloadSize ?? .NORMAL).rawValue,
                options: SelphiIadPayloadSize.allCases.map { $0.rawValue }
            ),
            "iadBundleTimeoutMs": .int(value: Int(selphiConfigurationData?.iadConfiguration.bundleTimeoutMs ?? 10_000)),
            "params": .string(value: params?.map { "\($0.key)=\($0.value)" }.joined(separator: "\n") ?? ""),
            "widgetParams": .string(value: widgetParams?.map { "\($0.key)=\($0.value)" }.joined(separator: "\n") ?? "")
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        let switchKeys: [String] = [
            "useDemoKmpCustomCameraOverlay",
            "showPreviousTip",
            "showTutorial",
            "showDiagnostic",
            "vibrationEnabled",
            "showResultAfterCapture",
            "qrMode",
            "iadEnabled"
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

        // Order matches non-switch keys in `values` above (UI row order only; Configuration.values is unordered).
        let fields: [String] = [
            "livenessMode",
            "qrTimeoutMs",
            "videoFilename",
            "cameraPreferred",
            "cameraShape",
            "qrCameraShape",
            "moveSuccessfulAttempts",
            "moveFailedAttempts",
            "maxAttempts",
            "extractionDuration",
            "extractionProgressMode",
            "videoBitRate",
            "videoBitRateValue",
            "iadPayloadSize",
            "iadBundleTimeoutMs",
            "params",
            "widgetParams"
        ]

        for key in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
