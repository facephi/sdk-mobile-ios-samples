//
//  VideoIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videoidComponent

extension SdkConfigurationManager {
    /// Same parameters as Android DemoVideoId SdkData.getVideoIdConfiguration.
    static func videoIDConfiguration(autoFace: Bool) -> VideoIDConfigurationData {
        VideoIDConfigurationData(
            mode: .FACE_DOCUMENT_FRONT_BACK,
            sectionTimeout: 20000,
            autoFaceDetection: autoFace,
            customerId: CUSTOMER_ID
        )
    }
}
