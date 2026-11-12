//
//  SelphIDExtractorV3.swift
//  demosdk
//
//  Demo-level init + configuration for extractorv3 (SDR).
//

import Foundation
import extractorv3

/// Builds a configured `DocumentExtractorV3` for the SelphID KMP demo host.
final class SelphIDExtractorV3 {

    var debugMode: Bool = false
    var readerMode: ExtractorV3ReaderMode = .documentMode
    var iqaThresholdPercent: Int32 = 60
    var backIqaThresholdPercent: Int32 = 45
    var countryFilter: [String]?
    var documentTypeFilter: [String]?
    var modelFilter: [String]?
    var wizardModeOverride: Bool?

    init() {}

    func makeConfiguration() -> ExtractorConfigurationV3 {
        ExtractorConfigurationV3(
            debugMode: debugMode,
            readerMode: readerMode,
            iqaThresholdPercent: iqaThresholdPercent,
            backIqaThresholdPercent: backIqaThresholdPercent,
            countryFilter: countryFilter,
            documentTypeFilter: documentTypeFilter,
            modelFilter: modelFilter
        )
    }

    func makeExtractor() -> DocumentExtractorV3 {
        return DocumentExtractorV3(
            configuration: makeConfiguration()
        )
    }
}
