//
//  VideoCallConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videocallComponent

extension SdkConfigurationManager {
    static var videoCallConfiguration: VideoCallConfigurationData {
        VideoCallConfigurationData(
            vibrationEnabled: true,
            activateScreenSharing: true,
            timeout: 60_000
        )
    }
}
