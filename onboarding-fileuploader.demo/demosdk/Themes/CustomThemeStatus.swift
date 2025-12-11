//
//  CustomThemeStatus.swift
//  demosdk
//
//  Created by Jorge Poveda on 24/7/24.
//

import Foundation
import UIKit
import statusComponent

class CustomThemeStatus: ThemeStatusProtocol {
    var name: String {
        "custom"
    }
    var images: [R.Image: UIImage?] = [:]
    
    var colors: [R.Color: UIColor?] = [:]
//    = [
//        R.Color.sdkPrimaryColor: UIColor.red,
//        R.Color.sdkBackgroundColor: .brown,
//        R.Color.sdkNeutralColor: UIColor.cyan,
//        .sdkAccentColor: .systemPink]
    
    var fonts: [R.Font: String] = [:] //= [R.Font.bold: "Comic Sans MS"]
    
    var dimensions: [R.Dimension: CGFloat] = [:]
}
