//
//  CustomTheme.swift
//  demosdk
//
//  Created by Faustino Flores García on 27/6/22.
//

import Foundation
import UIKit
import videocallComponent

class CustomThemeVideoCall: ThemeVideoCallProtocol {
    var images: [R.Image: UIImage?] = [:]
    
    var colors: [R.Color: UIColor?] = [R.Color.sdkPrimaryColor: UIColor.red]
    
    var animations: [R.Animation: String] = [
        R.Animation.video_call_anim_waiting: "nombre_archivo"]
    
    var name: String {
        "custom"
    }
    
    var fonts: [R.Font: String] = [:]
    
    var dimensions: [R.Dimension: CGFloat] {
        [.fontBig: 8]
    }
}
