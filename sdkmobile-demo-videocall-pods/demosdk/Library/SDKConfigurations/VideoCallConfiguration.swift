//
//  VideoCallConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videocallComponent

extension SdkConfigurationManager {
    static var videoCallConfiguration: VideoCallConfigurationData{
        var configVideoCall = VideoCallConfigurationData()
        configVideoCall.url = nil
        configVideoCall.apiKey = nil
        configVideoCall.tenantId = nil
        configVideoCall.vibrationEnabled = true
        configVideoCall.activateScreenSharing = true
        configVideoCall.timeout = 60000
        
        return configVideoCall
    }
}
