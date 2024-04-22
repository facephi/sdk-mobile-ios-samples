//
//  QrReaderConfiguration.swift
//  demosdk
//
//  Created by Jorge Poveda on 22/5/23.
//

import Foundation
import captureComponent

extension SdkConfigurationManager {
    static var qrReaderConfiguration: CaptureConfigurationData {
        return CaptureConfigurationData(extractionTimeout: 1000, cameraSelected: .BACK, cameraShape: .CIRCULAR)
    }
    
    static var qrGeneratorConfiguration: QrGeneratorConfigurationData {
        return QrGeneratorConfigurationData(source: "", width: 200, height: 200)
    }
}
