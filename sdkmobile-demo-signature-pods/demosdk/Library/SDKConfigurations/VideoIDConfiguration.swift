//
//  VideoIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videoidComponent

extension SdkConfigurationManager {
    static var videoIDConfiguration: VideoIDConfigurationData {
        var configVideoID = VideoIDConfigurationData(showCompletedTutorial: true)
        configVideoID.mode = .FACE_DOCUMENT_FRONT_BACK
        configVideoID.url = nil
        configVideoID.apiKey = nil
        configVideoID.tenantId = nil
        configVideoID.vibrationEnabled = true
        configVideoID.timeoutServerConnection = 15000
        configVideoID.sectionTime = 3000
        configVideoID.sectionTimeout = 10000
        configVideoID.cameraPreferred = .FRONT
        configVideoID.autoFaceDetection = true
        configVideoID.documentQualityThreshold = 0.7
        
        return configVideoID
    }
}
