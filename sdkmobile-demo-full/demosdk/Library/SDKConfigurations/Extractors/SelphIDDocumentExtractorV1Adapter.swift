//
//  SelphIDDocumentExtractorV1Adapter.swift
//  demosdk
//
//  Aligned with selphid-widget-kmp/iosAppCocoapods/DemoExtractorAdapters.swift
//

import Foundation
import extractorv1
import FPHISelphIDWidget

final class SelphIDDocumentExtractorV1Adapter: NSObject, FPHISelphIDWidget.PolicyAwareDocumentExtractor {
    private let extractor: extractorv1.DocumentExtractorV1

    init(extractor: extractorv1.DocumentExtractorV1) {
        self.extractor = extractor
        super.init()
    }

    var vendor: FPHISelphIDWidget.ExtractorcoreExtractorVendor {
        mapVendor(extractor.vendor)
    }

    var version: String {
        extractor.version
    }

    func supportsDocumentType(documentType: FPHISelphIDWidget.ExtractorcoreExtractorDocumentType) -> Bool {
        ["DTIDCard", "DTPassport", "DTVisa", "DTDriversLicense", "DTForeignCard"]
            .contains(documentType.name)
    }

    func warmupTimeoutMs() -> Int64 {
        0
    }

    func minimumAttemptTimeoutMs() -> Int64 {
        0
    }

    func allowsCapturedFrameFallback() -> Bool {
        true
    }

    func create(license: String, completionHandler: @escaping (FPHISelphIDWidget.ExtractorcoreExtractorError?, Error?) -> Void) {
        extractor.create(license: license) { error, swiftError in
            completionHandler(self.mapError(error), swiftError)
        }
    }

    func creationProgress() -> Int32 {
        extractor.creationProgress()
    }

    func destroy() {
        extractor.destroy()
    }

    func isReady() -> Bool {
        extractor.isReady()
    }

    func isProcessingImage() -> Bool {
        extractor.isProcessingImage()
    }

    func hasFullResetOnly() -> Bool {
        extractor.hasFullResetOnly()
    }

    func startExtraction() {
        extractor.startExtraction()
    }

    func reset() {
        extractor.reset()
    }

    func resetExtraction() {
        extractor.resetExtraction()
    }

    func setupInput(input: FPHISelphIDWidget.ExtractorcoreExtractorInput) {
        extractor.setupInput(input: mapInput(input))
    }

    func setupInput(
        width: Int32,
        height: Int32,
        rotation: FPHISelphIDWidget.ExtractorcoreExtractorImageRotation,
        format: FPHISelphIDWidget.ExtractorcoreExtractorImageFormat,
        roi: FPHISelphIDWidget.ExtractorcoreExtractorRect?,
        isStream: Bool
    ) {
        extractor.setupInput(
            width: width,
            height: height,
            rotation: mapRotation(rotation),
            format: mapFormat(format),
            roi: mapRectToExtractor(roi),
            isStream: isStream
        )
    }

    func setupExtraction(extractionConfiguration: FPHISelphIDWidget.ExtractorcoreExtractorConfiguration) -> FPHISelphIDWidget.ExtractorcoreExtractorError? {
        let result = extractor.setupExtraction(extractionConfiguration: mapConfiguration(extractionConfiguration))
        return mapError(result)
    }

    func extract(
        frameExtractor: FPHISelphIDWidget.ExtractorcoreFrameExtractor,
        completionHandler: @escaping (FPHISelphIDWidget.ExtractorcoreExtractorResult?, Error?) -> Void
    ) {
        extract(frameExtractor: frameExtractor, timeStamp: frameExtractor.time, completionHandler: completionHandler)
    }

    func extract(
        frameExtractor: FPHISelphIDWidget.ExtractorcoreFrameExtractor,
        timeStamp: Int64,
        completionHandler: @escaping (FPHISelphIDWidget.ExtractorcoreExtractorResult?, Error?) -> Void
    ) {
        extractor.extract(frameExtractor: mapFrame(frameExtractor), timeStamp: timeStamp) { result, error in
            if let error {
                completionHandler(nil, error)
                return
            }

            guard let result else {
                completionHandler(nil, nil)
                return
            }

            let bridge = extractorv1.DocumentExtractorBridgeKt.bridgeDocumentExtractorResult(result: result)
            let widgetBridge = self.mapBridgeResult(bridge)
            let widgetResult = FPHISelphIDWidget.WidgetExtractorBridgeKt.widgetExtractorResultFromBridge(result: widgetBridge)
            completionHandler(widgetResult, nil)
        }
    }

    private func mapVendor(_ vendor: extractorv1.ExtractorcoreExtractorVendor?) -> FPHISelphIDWidget.ExtractorcoreExtractorVendor {
        guard let vendor else { return .extractorV1 }
        return FPHISelphIDWidget.ExtractorcoreExtractorVendor.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorVendor }
            .first(where: { $0.name == vendor.name }) ?? .extractorV1
    }

    private func mapError(_ error: extractorv1.ExtractorcoreExtractorError?) -> FPHISelphIDWidget.ExtractorcoreExtractorError? {
        guard let error else { return nil }
        return FPHISelphIDWidget.ExtractorcoreExtractorError.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorError }
            .first(where: { $0.name == error.name })
    }

    private func mapRotation(_ rotation: FPHISelphIDWidget.ExtractorcoreExtractorImageRotation) -> extractorv1.ExtractorcoreExtractorImageRotation {
        extractorv1.ExtractorcoreExtractorImageRotation.entries
            .compactMap { $0 as? extractorv1.ExtractorcoreExtractorImageRotation }
            .first(where: { $0.name == rotation.name }) ?? .none
    }

    private func mapFormat(_ format: FPHISelphIDWidget.ExtractorcoreExtractorImageFormat) -> extractorv1.ExtractorcoreExtractorImageFormat {
        extractorv1.ExtractorcoreExtractorImageFormat.entries
            .compactMap { $0 as? extractorv1.ExtractorcoreExtractorImageFormat }
            .first(where: { $0.name == format.name }) ?? .rgba
    }

    private func mapRectToExtractor(_ rect: FPHISelphIDWidget.ExtractorcoreExtractorRect?) -> extractorv1.ExtractorcoreExtractorRect? {
        guard let rect else { return nil }
        return extractorv1.ExtractorcoreExtractorRect(
            left: rect.left,
            top: rect.top,
            right: rect.right,
            bottom: rect.bottom
        )
    }

    private func mapInput(_ input: FPHISelphIDWidget.ExtractorcoreExtractorInput) -> extractorv1.ExtractorcoreExtractorInput {
        extractorv1.ExtractorcoreExtractorInput(
            width: input.width,
            height: input.height,
            rotation: mapRotation(input.rotation),
            format: mapFormat(input.format),
            roi: mapRectToExtractor(input.roi),
            isStream: input.isStream
        )
    }

    private func mapDocumentType(_ documentType: FPHISelphIDWidget.ExtractorcoreExtractorDocumentType) -> extractorv1.ExtractorcoreExtractorDocumentType {
        extractorv1.ExtractorcoreExtractorDocumentType.entries
            .compactMap { $0 as? extractorv1.ExtractorcoreExtractorDocumentType }
            .first(where: { $0.name == documentType.name }) ?? .dtidcard
    }

    private func mapCaptureMode(_ mode: FPHISelphIDWidget.ExtractorcoreExtractorCaptureMode) -> extractorv1.ExtractorcoreExtractorCaptureMode {
        extractorv1.ExtractorcoreExtractorCaptureMode.entries
            .compactMap { $0 as? extractorv1.ExtractorcoreExtractorCaptureMode }
            .first(where: { $0.name == mode.name }) ?? .front
    }

    private func mapCaptureStep(_ step: FPHISelphIDWidget.ExtractorcoreExtractorCaptureStep) -> extractorv1.ExtractorcoreExtractorCaptureStep {
        extractorv1.ExtractorcoreExtractorCaptureStep.entries
            .compactMap { $0 as? extractorv1.ExtractorcoreExtractorCaptureStep }
            .first(where: { $0.name == step.name }) ?? .front
    }

    private func mapBoolean(_ value: FPHISelphIDWidget.KotlinBoolean?) -> extractorv1.KotlinBoolean? {
        guard let value else { return nil }
        return extractorv1.KotlinBoolean(bool: value.boolValue)
    }

    private func mapConfiguration(_ configuration: FPHISelphIDWidget.ExtractorcoreExtractorConfiguration) -> extractorv1.ExtractorcoreExtractorConfiguration {
        extractorv1.ExtractorcoreExtractorConfiguration(
            capture: extractorv1.ExtractorcoreExtractorCaptureConfiguration(
                mode: mapCaptureMode(configuration.capture.mode),
                step: mapCaptureStep(configuration.capture.step),
                encodedDataFocus: configuration.capture.encodedDataFocus
            ),
            filter: extractorv1.ExtractorcoreExtractorDocumentFilter(
                documentType: mapDocumentType(configuration.filter.documentType),
                documentTypes: configuration.filter.documentTypes
                    .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorDocumentType }
                    .map { mapDocumentType($0) },
                documentVersion: configuration.filter.documentVersion,
                documentCountry: configuration.filter.documentCountry,
                documentCountries: configuration.filter.documentCountries.compactMap { $0 as? String },
                documentModels: configuration.filter.documentModels.compactMap { $0 as? String }
            ),
            output: extractorv1.ExtractorcoreExtractorOutputConfiguration(
                generateRawImages: mapBoolean(configuration.output.generateRawImages), enableDebugData: false
            )
        )
    }

    private func mapFrame(_ frame: FPHISelphIDWidget.ExtractorcoreFrameExtractor) -> extractorv1.ExtractorcoreFrameExtractor {
        extractorv1.ExtractorcoreFrameExtractor(
            image: frame.toNativeImage(),
            imageWidth: frame.width,
            imageHeight: frame.height,
            imageRotation: frame.rotation,
            time: frame.time
        )
    }

    private func mapBridgeKind(_ kind: extractorv1.DocumentExtractorBridgeKind) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeKind {
        FPHISelphIDWidget.ExtractorcoreExtractorBridgeKind.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorBridgeKind }
            .first(where: { $0.name == kind.name }) ?? .error
    }

    private func mapBridgeIqa(_ iqa: extractorv1.DocumentExtractorBridgeIqa?) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeIqa? {
        guard let iqa else { return nil }
        return FPHISelphIDWidget.ExtractorcoreExtractorBridgeIqa(
            overExposure: iqa.overExposure,
            underExposure: iqa.underExposure,
            sharpness: iqa.sharpness,
            readability: iqa.readability
        )
    }

    private func mapFrameEntry(_ entry: extractorv1.DocumentExtractorBridgeFrameEntry) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeFrameEntry {
        let frame = FPHISelphIDWidget.ExtractorcoreFrameExtractor(
            image: entry.frame.toNativeImage(),
            imageWidth: entry.frame.width,
            imageHeight: entry.frame.height,
            imageRotation: entry.frame.rotation,
            time: entry.frame.time
        )
        return FPHISelphIDWidget.ExtractorcoreExtractorBridgeFrameEntry(
            key: entry.key,
            frame: frame
        )
    }

    private func mapDocumentType(_ documentType: extractorv1.ExtractorcoreExtractorDocumentType?) -> FPHISelphIDWidget.ExtractorcoreExtractorDocumentType? {
        guard let documentType else { return nil }
        return FPHISelphIDWidget.ExtractorcoreExtractorDocumentType.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorDocumentType }
            .first(where: { $0.name == documentType.name })
    }

    private func mapBridgeData(_ data: extractorv1.DocumentExtractorBridgeData?) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeData? {
        guard let data else { return nil }
        let mapped = FPHISelphIDWidget.ExtractorcoreExtractorBridgeData(
            message: data.message,
            iqa: mapBridgeIqa(data.iqa),
            ocrEntries: data.ocrEntries.map { entry in
                FPHISelphIDWidget.ExtractorcoreExtractorBridgeOcrEntry(key: entry.key, value: entry.value)
            },
            frameEntries: data.frameEntries.map(mapFrameEntry),
            documentCountry: data.documentCountry,
            documentType: mapDocumentType(data.documentType),
            documentVersion: data.documentVersion,
            documentCaptured: data.documentCaptured,
            documentClass: data.documentClass,
            morePagesAvailable: data.morePagesAvailable,
            finished: data.finished
        )
        mapped.universalOcr = data.universalOcr
        return mapped
    }

    private func mapBridgeVendorData(_ data: extractorv1.DocumentExtractorBridgeVendorData) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeVendorData {
        FPHISelphIDWidget.ExtractorcoreExtractorBridgeVendorData(
            vendor: mapVendor(data.vendor),
            data: mapBridgeData(data.data)!
        )
    }

    private func mapBridgeResult(_ result: extractorv1.DocumentExtractorBridgeResult) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeResult {
        let mappedKind = mapBridgeKind(result.kind)
        return FPHISelphIDWidget.ExtractorcoreExtractorBridgeResult(
            kind: mappedKind,
            error: mapError(result.error),
            success: mapBridgeData(result.success),
            primary: mapBridgeData(result.primary),
            primaryVendor: mapVendor(result.primaryVendor),
            results: result.results.map(mapBridgeVendorData),
            encodedDataFocusItems: [],
            encodedDataFocusCaptureStep: nil
        )
    }
}
