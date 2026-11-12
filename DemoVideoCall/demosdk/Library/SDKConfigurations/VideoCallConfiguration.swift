//
//  VideoCallConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videocallComponent

extension SdkConfigurationManager {
    /// Same parameters as Android DemoVideoCall SdkData.videoCallConfiguration.
    static var videoCallConfiguration: VideoCallConfigurationData {
        VideoCallConfigurationData(
            customerId: CUSTOMER_ID,
            email: CUSTOMER_ID
        )
    }
}
