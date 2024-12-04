//
//  VideoIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videoidComponent

extension SdkConfigurationManager {
    static var videoIDConfiguration: VideoIDConfigurationData{
        var configVideoID = VideoIDConfigurationData(showCompletedTutorial: true)
        
        return configVideoID
    }
}
