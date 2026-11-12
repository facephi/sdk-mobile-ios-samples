//
//  SelphIDExtractorV1.swift
//  demosdk
//
//  Demo-level init + configuration for extractorv1 (BlinkID).
//

import Foundation
import extractorv1

/// Builds a configured `DocumentExtractorV1` for the SelphID KMP demo host.
final class SelphIDExtractorV1 {

    var allowUncertainFrontSideScan: Bool = false
    var stepTimeoutDurationSeconds: Double = 10
    var inputImageMargin: Double = 0
    var scanCroppedDocumentImage: Bool = false
    var saveMrzDiagnosticImages: Bool = false

    init() {}

    /// Configuration applied when creating the extractor.
    func makeConfiguration() -> ExtractorConfigurationV1 {
        ExtractorConfigurationV1(
            allowUncertainFrontSideScan: allowUncertainFrontSideScan,
            stepTimeoutDurationSeconds: stepTimeoutDurationSeconds,
            inputImageMargin: inputImageMargin,
            scanCroppedDocumentImage: scanCroppedDocumentImage,
            saveMrzDiagnosticImages: saveMrzDiagnosticImages
        )
    }

    /// Returns a ready-to-inject `DocumentExtractorV1` instance.
    func makeExtractor() -> DocumentExtractorV1 {
        DocumentExtractorV1(configuration: makeConfiguration())
    }
}
