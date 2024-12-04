//
//  VideoCallConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videocallComponent

extension SdkConfigurationManager {
    static var videoCallConfiguration: VideoCallConfigurationData{
        var configVideoCall = VideoCallConfigurationData(url: nil,
                                                         apiKey: nil,
                                                         tenantId: nil,
                                                         vibrationEnabled: true,
                                                         activateScreenSharing: true,
                                                         timeout: 30000)
        return configVideoCall
    }
}
