//
//  VideoIDConfiguration.swift
//  demosdk
//
//  Created by Carlos Cantos on 26/9/23.
//

import videoidComponent

extension SdkConfigurationManager {
    /// Default VideoID config aligned with sdkmobile-demo-full-pods (SDK 4.0.0).
    static var videoIDConfiguration: VideoIDConfigurationData {
        VideoIDConfigurationData(showCompletedTutorial: true)
    }
}
