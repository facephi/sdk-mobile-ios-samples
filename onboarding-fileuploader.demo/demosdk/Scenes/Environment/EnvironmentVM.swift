//
//  EnvironmentVM.swift
//  demosdk
//
//  Created by Faustino Flores García on 15/6/22.
//

import core
import sdk
import Foundation

protocol EnvironmentVMInput {
    func getConfigurationData()
    func setConfigurationData(_ configurationData: ConfigurationDataModel)
}

protocol EnvironmentVMOutput {
    func configurationDataIsGet(_ configurationData: ConfigurationDataModel)
    func configurationDataIsSet()
}

class EnvironmentVM {
    // MARK: - VARS
    private var delegate: EnvironmentVMOutput!

    init(delegate: EnvironmentVMOutput) {
        self.delegate = delegate
    }
}

extension EnvironmentVM: EnvironmentVMInput {
    func setConfigurationData(_ configurationData: ConfigurationDataModel) {
        PrefManager.set(configurationData.trackingVersion.rawValue, forKey: .KEY_TRACKING_VERSION)
        PrefManager.set(configurationData.customerId, forKey: .KEY_CUSTOMER_ID)
        PrefManager.set(configurationData.flowID, forKey: .KEY_FLOW_ID)
        PrefManager.set(configurationData.operationType.rawValue, forKey: .KEY_OPERATION_TYPE)
        PrefManager.set(configurationData.locale.rawValue, forKey: .KEY_LOCALE)        
        PrefManager.set(configurationData.launch_main_background, forKey: .KEY_LAUNCH_MAIN_BACKGROUND)
        
        SDKManager.shared = SDKManager(trackingVersion: configurationData.trackingVersion, locale: configurationData.locale)
        delegate.configurationDataIsSet()
    }

    func getConfigurationData() {
        delegate.configurationDataIsGet(ConfigurationDataModel())
    }
}

struct ConfigurationDataModel {
    let version: String
    
    let trackingVersion: TrackingVersion
    let customerId: String
    let flowID: String
    
    let operationType: OperationType
    let locale: SdkLocale
    
    let launch_main_background: Bool
    
    init(trackingVersion: TrackingVersion,
         customerId: String,
         operationType: OperationType,
         locale: SdkLocale,
         flowID: String,
         launch_main_background: Bool)
         
    {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        
        self.trackingVersion = trackingVersion
        self.version = "General - Versión: \(version) (\(build))"
        self.customerId = customerId
        self.operationType = operationType
        self.locale = locale
        self.flowID = flowID
        
        self.launch_main_background = launch_main_background
    }
    
    init() {
        self.init(
            trackingVersion: PrefManager.get(.v2_STG, forKey: .KEY_TRACKING_VERSION),
            customerId: PrefManager.get(String.self, forKey: .KEY_CUSTOMER_ID) ?? "",
            operationType: PrefManager.get(.ONBOARDING, forKey: .KEY_OPERATION_TYPE),
            locale: PrefManager.get(.es, forKey: .KEY_LOCALE),
            flowID: PrefManager.get(String.self, forKey: .KEY_FLOW_ID) ?? "",
            launch_main_background: PrefManager.get(Bool.self, forKey: .KEY_LAUNCH_MAIN_BACKGROUND) ?? true
        )
    }
}

enum TrackingVersion: String, CaseIterable {
    case v2_STG
    case v2_DEV
}

enum SdkLocale: String, CaseIterable {
    case es
    case en
    case pt
    case ptBR = "pt-BR"
    case ca
}
