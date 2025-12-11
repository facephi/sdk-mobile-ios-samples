//
//  FinishTrackingData.swift
//  demosdk
//
//  Created by Carlos Cantos on 3/10/24.
//

import Foundation
import UIKit
import sdk

struct FinishTrackingData {
    var family: OperationType
    var status: FinishTrackingStatus
    var reason: FinishTrackingReason
}

enum FinishTrackingStatus: String, Codable, CaseIterable {
    case SUCCEEDED
    case DENIED
    case ERROR
    case CANCELLED
    case BLACKLISTED
}

enum FinishTrackingReason: String, Codable, CaseIterable {
    case NONE = ""
    case DOCUMENT_VALIDATION_NOT_PASSED
    case DOCUMENT_VALIDATION_ERROR
    case FACIAL_AUTHENTICATION_NOT_PASSED
    case FACIAL_AUTHENTICATION_ERROR
    case FACIAL_LIVENESS_NOT_PASSED
    case FACIAL_LIVENESS_ERROR
    case BLACKLISTED_FACE_TEMPLATE
    case ALREADY_REGISTERED
    case MANUAL_STATUS_CHANGE
    case SECURITY_SERVICE_ERROR
    case SELPHID_INTERNAL_ERROR
    case SELPHID_TIMEOUT
    case SELPHI_TIMEOUT
}

extension OperationType {
    func toIdApiString() -> String {
        switch self {
        case .AUTHENTICATION:
            return "Authentication"
        default:
            return "OnBoarding"
        }
    }
}

extension SdkConfigurationManager {
    static func createFinishTrackingData(from configuration: Configuration) -> FinishTrackingData {
        let family: OperationType = PrefManager.get(String.self, forKey: .KEY_OPERATION_TYPE) == "AUTHENTICATION" ? .AUTHENTICATION: .ONBOARDING
        var status = FinishTrackingStatus.SUCCEEDED
        var reason = FinishTrackingReason.NONE

        for (key, value) in configuration.values {
            switch (key, value) {
            case ("status", .enumValueCombo(let val, _)):
                if let enumVal = FinishTrackingStatus(rawValue: val) {
                    status = enumVal
                }
            case ("reason", .enumValueCombo(let val, _)):
                if let enumVal = FinishTrackingReason(rawValue: val) {
                    reason = enumVal
                }
            default:
                break
            }
        }
        
        return FinishTrackingData(
            family: family,
            status: status,
            reason: reason)
    }
    
    static func configureFinishTrackingFields(in viewController: ConfigsComponentsVC,
                                              with finishTrackingData: FinishTrackingData?) {
        if viewController.configuration == nil {
            viewController.configuration = Configuration(configType: .FINISH_TRACKING, values: [:])
        }

        let values: [String: ConfigValue] = [
            "status": .enumValueCombo(value: (finishTrackingData?.status ?? .SUCCEEDED).rawValue, options: FinishTrackingStatus.allCases.map { $0.rawValue }),
            "reason": .enumValueCombo(value: (finishTrackingData?.reason ?? .NONE).rawValue, options: FinishTrackingReason.allCases.map { $0.rawValue }),
        ]

        viewController.configuration!.values.merge(values) { (_, new) in new }

        let stackView = viewController.stackView

        // Agregar los campos generados con `createField`
        let fields: [String] = [
            ("status"),
            ("reason")
        ]

        for (key) in fields {
            if let value = viewController.configuration!.values[key] {
                stackView.addArrangedSubview(viewController.createField(key: key, value: value))
            }
        }
    }
}
