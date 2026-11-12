//
//  SelphIDDocumentExtractorV3Adapter.swift
//  demosdk
//
//  Aligned with selphid-widget-kmp/iosAppCocoapods/DemoExtractorAdaptersV3V4.swift
//

import Foundation
import extractorv3
import FPHISelphIDWidget

final class SelphIDDocumentExtractorV3Adapter: NSObject, FPHISelphIDWidget.CaptureRetryAwareDocumentExtractor {
    private let extractor: extractorv3.DocumentExtractorV3

    init(extractor: extractorv3.DocumentExtractorV3) {
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
        ["DTIDCard", "DTDriversLicense", "DTForeignCard"].contains(documentType.name)
    }

    func warmupTimeoutMs() -> Int64 {
        0
    }

    func minimumAttemptTimeoutMs() -> Int64 {
        10_000
    }

    func allowsCapturedFrameFallback() -> Bool {
        false
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

    func rollbackCurrentSide() {
        extractor.rollbackCurrentSide()
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

            let bridge = extractorv3.DocumentExtractorBridgeKt.bridgeDocumentExtractorResult(result: result)
            let widgetBridge = self.mapBridgeResult(bridge)
            let widgetResult = FPHISelphIDWidget.WidgetExtractorBridgeKt.widgetExtractorResultFromBridge(result: widgetBridge)
            completionHandler(widgetResult, nil)
        }
    }

    private func mapVendor(_ vendor: extractorv3.ExtractorcoreExtractorVendor?) -> FPHISelphIDWidget.ExtractorcoreExtractorVendor {
        guard let vendor else { return .extractorV3 }
        return FPHISelphIDWidget.ExtractorcoreExtractorVendor.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorVendor }
            .first(where: { $0.name == vendor.name }) ?? .extractorV3
    }

    private func mapError(_ error: extractorv3.ExtractorcoreExtractorError?) -> FPHISelphIDWidget.ExtractorcoreExtractorError? {
        guard let error else { return nil }
        return FPHISelphIDWidget.ExtractorcoreExtractorError.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorError }
            .first(where: { $0.name == error.name })
    }

    private func mapRotation(_ rotation: FPHISelphIDWidget.ExtractorcoreExtractorImageRotation) -> extractorv3.ExtractorcoreExtractorImageRotation {
        extractorv3.ExtractorcoreExtractorImageRotation.entries
            .compactMap { $0 as? extractorv3.ExtractorcoreExtractorImageRotation }
            .first(where: { $0.name == rotation.name }) ?? .none
    }

    private func mapFormat(_ format: FPHISelphIDWidget.ExtractorcoreExtractorImageFormat) -> extractorv3.ExtractorcoreExtractorImageFormat {
        extractorv3.ExtractorcoreExtractorImageFormat.entries
            .compactMap { $0 as? extractorv3.ExtractorcoreExtractorImageFormat }
            .first(where: { $0.name == format.name }) ?? .rgba
    }

    private func mapRectToExtractor(_ rect: FPHISelphIDWidget.ExtractorcoreExtractorRect?) -> extractorv3.ExtractorcoreExtractorRect? {
        guard let rect else { return nil }
        return extractorv3.ExtractorcoreExtractorRect(
            left: rect.left,
            top: rect.top,
            right: rect.right,
            bottom: rect.bottom
        )
    }

    private func mapInput(_ input: FPHISelphIDWidget.ExtractorcoreExtractorInput) -> extractorv3.ExtractorcoreExtractorInput {
        extractorv3.ExtractorcoreExtractorInput(
            width: input.width,
            height: input.height,
            rotation: mapRotation(input.rotation),
            format: mapFormat(input.format),
            roi: mapRectToExtractor(input.roi),
            isStream: input.isStream
        )
    }

    private func mapDocumentType(_ documentType: FPHISelphIDWidget.ExtractorcoreExtractorDocumentType) -> extractorv3.ExtractorcoreExtractorDocumentType {
        extractorv3.ExtractorcoreExtractorDocumentType.entries
            .compactMap { $0 as? extractorv3.ExtractorcoreExtractorDocumentType }
            .first(where: { $0.name == documentType.name }) ?? .dtidcard
    }

    private func mapCaptureMode(_ mode: FPHISelphIDWidget.ExtractorcoreExtractorCaptureMode) -> extractorv3.ExtractorcoreExtractorCaptureMode {
        extractorv3.ExtractorcoreExtractorCaptureMode.entries
            .compactMap { $0 as? extractorv3.ExtractorcoreExtractorCaptureMode }
            .first(where: { $0.name == mode.name }) ?? .front
    }

    private func mapCaptureStep(_ step: FPHISelphIDWidget.ExtractorcoreExtractorCaptureStep) -> extractorv3.ExtractorcoreExtractorCaptureStep {
        extractorv3.ExtractorcoreExtractorCaptureStep.entries
            .compactMap { $0 as? extractorv3.ExtractorcoreExtractorCaptureStep }
            .first(where: { $0.name == step.name }) ?? .front
    }

    private func mapBoolean(_ value: FPHISelphIDWidget.KotlinBoolean?) -> extractorv3.KotlinBoolean? {
        guard let value else { return nil }
        return extractorv3.KotlinBoolean(bool: value.boolValue)
    }

    private func mapConfiguration(_ configuration: FPHISelphIDWidget.ExtractorcoreExtractorConfiguration) -> extractorv3.ExtractorcoreExtractorConfiguration {
        extractorv3.ExtractorcoreExtractorConfiguration(
            capture: extractorv3.ExtractorcoreExtractorCaptureConfiguration(
                mode: mapCaptureMode(configuration.capture.mode),
                step: mapCaptureStep(configuration.capture.step),
                encodedDataFocus: configuration.capture.encodedDataFocus
            ),
            filter: extractorv3.ExtractorcoreExtractorDocumentFilter(
                documentType: mapDocumentType(configuration.filter.documentType),
                documentTypes: configuration.filter.documentTypes
                    .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorDocumentType }
                    .map { mapDocumentType($0) },
                documentVersion: configuration.filter.documentVersion,
                documentCountry: configuration.filter.documentCountry,
                documentCountries: configuration.filter.documentCountries.compactMap { $0 as? String },
                documentModels: configuration.filter.documentModels.compactMap { $0 as? String }
            ),
            output: extractorv3.ExtractorcoreExtractorOutputConfiguration(
                generateRawImages: mapBoolean(configuration.output.generateRawImages),
                enableDebugData: false
            )
        )
    }

    private func mapFrame(_ frame: FPHISelphIDWidget.ExtractorcoreFrameExtractor) -> extractorv3.ExtractorcoreFrameExtractor {
        extractorv3.ExtractorcoreFrameExtractor(
            image: frame.toNativeImage(),
            imageWidth: frame.width,
            imageHeight: frame.height,
            imageRotation: frame.rotation,
            time: frame.time
        )
    }

    private func mapBridgeKind(_ kind: extractorv3.DocumentExtractorBridgeKind) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeKind {
        FPHISelphIDWidget.ExtractorcoreExtractorBridgeKind.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorBridgeKind }
            .first(where: { $0.name == kind.name }) ?? .error
    }

    private func mapBridgeIqa(_ iqa: extractorv3.DocumentExtractorBridgeIqa?) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeIqa? {
        guard let iqa else { return nil }
        return FPHISelphIDWidget.ExtractorcoreExtractorBridgeIqa(
            overExposure: iqa.overExposure,
            underExposure: iqa.underExposure,
            sharpness: iqa.sharpness,
            readability: iqa.readability
        )
    }

    private func mapFrameToWidget(_ frame: extractorv3.ExtractorcoreFrameExtractor) -> FPHISelphIDWidget.ExtractorcoreFrameExtractor {
        FPHISelphIDWidget.ExtractorcoreFrameExtractor(
            image: frame.toNativeImage(),
            imageWidth: frame.width,
            imageHeight: frame.height,
            imageRotation: frame.rotation,
            time: frame.time
        )
    }

    private func mapFrameEntry(_ entry: extractorv3.DocumentExtractorBridgeFrameEntry) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeFrameEntry {
        FPHISelphIDWidget.ExtractorcoreExtractorBridgeFrameEntry(
            key: entry.key,
            frame: mapFrameToWidget(entry.frame)
        )
    }

    private func mapDocumentType(_ documentType: extractorv3.ExtractorcoreExtractorDocumentType?) -> FPHISelphIDWidget.ExtractorcoreExtractorDocumentType? {
        guard let documentType else { return nil }
        return FPHISelphIDWidget.ExtractorcoreExtractorDocumentType.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorDocumentType }
            .first(where: { $0.name == documentType.name })
    }

    private func mapBridgeData(_ data: extractorv3.DocumentExtractorBridgeData?) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeData? {
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
        // Each framework exports its own KotlinDouble, so the number is rebuilt across the boundary.
        mapped.vendorMatchingSidesScore = data.vendorMatchingSidesScore.map {
            FPHISelphIDWidget.KotlinDouble(double: $0.doubleValue)
        }
        return mapped
    }

    private func mapBridgeVendorData(_ data: extractorv3.DocumentExtractorBridgeVendorData) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeVendorData {
        FPHISelphIDWidget.ExtractorcoreExtractorBridgeVendorData(
            vendor: mapVendor(data.vendor),
            data: mapBridgeData(data.data)!
        )
    }

    private func mapBridgeResult(_ result: extractorv3.DocumentExtractorBridgeResult) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeResult {
        let mappedKind = mapBridgeKind(result.kind)
        let mapped = FPHISelphIDWidget.ExtractorcoreExtractorBridgeResult(
            kind: mappedKind,
            error: mapError(result.error),
            success: mapBridgeData(result.success),
            primary: mapBridgeData(result.primary),
            primaryVendor: mapVendor(result.primaryVendor),
            results: result.results.map(mapBridgeVendorData),
            encodedDataFocusItems: result.encodedDataFocusItems.map(mapEncodedDataFocusItem),
            encodedDataFocusCaptureStep: mapCaptureStepToWidget(result.encodedDataFocusCaptureStep)
        )
        // Outside the Kotlin constructor (ABI), so it is copied across the framework boundary by hand.
        mapped.encodedDataFocusDocumentImage = result.encodedDataFocusDocumentImage.map(mapFrameToWidget)
        return mapped
    }

    private func mapEncodedDataFocusItem(
        _ item: extractorv3.DocumentExtractorBridgeEncodedDataFocusItem
    ) -> FPHISelphIDWidget.ExtractorcoreExtractorBridgeEncodedDataFocusItem {
        FPHISelphIDWidget.ExtractorcoreExtractorBridgeEncodedDataFocusItem(
            format: item.format,
            topLeftX: item.topLeftX,
            topLeftY: item.topLeftY,
            topRightX: item.topRightX,
            topRightY: item.topRightY,
            bottomLeftX: item.bottomLeftX,
            bottomLeftY: item.bottomLeftY,
            bottomRightX: item.bottomRightX,
            bottomRightY: item.bottomRightY,
            captured: item.captured
        )
    }

    private func mapCaptureStepToWidget(
        _ step: extractorv3.ExtractorcoreExtractorCaptureStep?
    ) -> FPHISelphIDWidget.ExtractorcoreExtractorCaptureStep? {
        guard let step else { return nil }
        return FPHISelphIDWidget.ExtractorcoreExtractorCaptureStep.entries
            .compactMap { $0 as? FPHISelphIDWidget.ExtractorcoreExtractorCaptureStep }
            .first(where: { $0.name == step.name })
    }
}
