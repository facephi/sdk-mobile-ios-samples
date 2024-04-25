//
//  VideoIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videoidComponent

extension SdkConfigurationManager {
    static var videoIDConfiguration: EnvironmentVideoIdData{
        var configVideoID = EnvironmentVideoIdData(showCompletedTutorial: true)
        
        return configVideoID
    }
}
