//
//  FileUploaderConfiguration.swift
//  demosdk
//

import captureComponent
import Foundation
import videoRecordingComponent

extension SdkConfigurationManager {
    /// Android SdkData.getVideoRecording().
    static var videoRecordingConfiguration: VideoRecordingConfigurationData {
        VideoRecordingConfigurationData()
    }

    /// Android SdkData.getFileUploaderDConfiguration(...).
    static func fileUploaderConfiguration(
        allowGallery: Bool = true,
        showPreviousTip: Bool = true,
        showDiagnostic: Bool = true,
        maxScannedDocs: Int = 2
    ) -> FileUploaderConfigurationData {
        FileUploaderConfigurationData(
            showDiagnostic: showDiagnostic,
            showPreviousTip: showPreviousTip,
            maxScannedDocs: maxScannedDocs,
            allowGallery: allowGallery
        )
    }
}
