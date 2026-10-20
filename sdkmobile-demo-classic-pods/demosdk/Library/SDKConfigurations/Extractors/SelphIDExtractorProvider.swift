//
//  SelphIDExtractorProvider.swift
//  demosdk
//
//  Builds host document extractors passed to `SelphIDController`.
//

import Foundation
import FPHISelphIDWidget

enum SelphIDExtractorProvider {

    /// Returns host extractors for `SelphIDController` (same pattern as iosAppCocoapods).
    static func makeAllExtractors(
        v1: SelphIDExtractorV1 = SelphIDExtractorV1(),
        v2: SelphIDExtractorV2 = SelphIDExtractorV2(),
        v3: SelphIDExtractorV3 = SelphIDExtractorV3()
    ) -> [FPHISelphIDWidget.ExtractorcoreDocumentExtractor] {
        [
            SelphIDDocumentExtractorV3Adapter(extractor: v3.makeExtractor()),
//            SelphIDDocumentExtractorV1Adapter(extractor: v1.makeExtractor()),
//            SelphIDDocumentExtractorV2Adapter(extractor: v2.makeExtractor()),
        ]
    }
}
