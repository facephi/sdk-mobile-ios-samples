//
//  SelphIDExtractorV2.swift
//  demosdk
//
//  Demo-level init + configuration for extractorv2 (Regula).
//

import Foundation
import extractorv2

/// Builds a configured `DocumentExtractorV2` for the SelphID KMP demo host.
final class SelphIDExtractorV2 {

    private static let regulaOptionalTimeoutMs: Int64 = 4_000

    /// Regula scenario name (e.g. `AUTO`). Matched against `RegulaScenario.entries`.
    var scenarioName: String = "AUTO"
    var timeoutSeconds: Double = 600
    var enableLogs: Bool = true
    /// Field requirement mode applied to face/mrz/pdf417/barcode on both sides.
    var fieldRequirementMode: RegulaFieldMode = .disabled

    init() {}

    static var availableScenarioNames: [String] {
        RegulaScenario.entries.map { $0.name }
    }

    func makeConfiguration() -> ExtractorConfigurationV2 {
        let scenario = RegulaScenario.entries
            .compactMap { $0 as? RegulaScenario }
            .first(where: { $0.name == scenarioName }) ?? .auto_

        let requirement = RegulaFieldRequirement(
            mode: fieldRequirementMode,
            optionalTimeoutMs: Self.regulaOptionalTimeoutMs
        )
        let sideRequirements = RegulaFieldRequirements(
            face: requirement,
            mrz: requirement,
            pdf417: requirement,
            barcode: requirement
        )
        let fieldRequirements = RegulaFieldRequirementsBySide(
            front: sideRequirements,
            back: sideRequirements
        )

        return ExtractorConfigurationV2(
            fieldRequirements: fieldRequirements,
            scenario: scenario,
            timeoutSeconds: timeoutSeconds,
            enableLogs: enableLogs,
            documentIdCatalog: []
        )
    }

    func makeExtractor() -> DocumentExtractorV2 {
        DocumentExtractorV2(configuration: makeConfiguration())
    }
}
