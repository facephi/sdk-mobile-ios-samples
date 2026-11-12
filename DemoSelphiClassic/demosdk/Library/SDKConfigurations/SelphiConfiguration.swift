//
//  SelphiConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import selphiClassicComponent

extension SdkConfigurationManager {
    /// Same as Android SdkData.SELPHI_RESOURCES: widget resources zip bundled with the app.
    static let SELPHI_RESOURCES: String = Bundle.main.path(
        forResource: "fphi-selphi-widget-resources-sdk",
        ofType: "zip"
    ) ?? ""

    /// Equivalent of Android DemoSelphiClassic SdkData.getSelphiConfiguration.
    static func selphiConfiguration(
        showTutorial: Bool,
        showPreviousTip: Bool,
        showDiagnostic: Bool
    ) -> SelphiConfigurationData {
        var configSelphi = SelphiConfigurationData()

        configSelphi.showTutorial = showTutorial
        configSelphi.showPreviousTip = showPreviousTip
        configSelphi.showDiagnostic = showDiagnostic
        configSelphi.resourcesPath = SELPHI_RESOURCES

        return configSelphi
    }
}
