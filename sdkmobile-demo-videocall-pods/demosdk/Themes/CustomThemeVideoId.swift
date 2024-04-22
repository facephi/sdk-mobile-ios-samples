//
//  CustomThemeVideoId.swift
//  demosdk
//
//  Created by Faustino Flores García on 27/6/22.
//

import Foundation
import UIKit
import videoidComponent

class CustomThemeVideoId: ThemeVideoIdProtocol {
    var images: [R.Image: UIImage?] = [:]
    
    var colors: [R.Color: UIColor?] = [R.Color.sdkTitleTextColor: UIColor.red]
    
    // var animations: [R.Animation: String] = [:]
    
    var name: String {
        "custom"
    }
    
    var fonts: [R.Font: String] = [:]
    
    var dimensions: [R.Dimension: CGFloat] {
        [.fontBig: 8]
    }
}
