//
//  VideoIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videoidComponent

extension SdkConfigurationManager {
    static var videoIDConfiguration: VideoIDConfigurationData{
        var configVideoID = VideoIDConfigurationData(sectionTime: 5000,
                                                     mode: .FACE_DOCUMENT_FRONT_BACK,
                                                     url: nil,
                                                     apiKey: nil,
                                                     tenantId: nil,
                                                     showCompletedTutorial: true,
                                                     vibrationEnabled: true)
        
        return configVideoID
    }
}
