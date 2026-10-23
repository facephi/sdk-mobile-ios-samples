//
//  SelphIDExtractorProvider.swift
//  demosdk
//
//  Builds host document extractors passed to `SelphIDController`.
//

import Foundation
import FPHISelphIDWidget

enum SelphIDExtractorProvider {

    /// Same as Android SdkData.selphIdExtractors: [DocumentExtractorV3(), DocumentExtractorV1()].
    static func makeAllExtractors(
        v1: SelphIDExtractorV1 = SelphIDExtractorV1(),
        v3: SelphIDExtractorV3 = SelphIDExtractorV3()
    ) -> [FPHISelphIDWidget.ExtractorcoreDocumentExtractor] {
        [
            SelphIDDocumentExtractorV3Adapter(extractor: v3.makeExtractor()),
            SelphIDDocumentExtractorV1Adapter(extractor: v1.makeExtractor()),
        ]
    }
}
