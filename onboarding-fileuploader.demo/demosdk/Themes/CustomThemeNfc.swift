//
//  CustomThemeNfc.swift
//  demosdk
//
//  Created by Jorge Poveda on 4/9/24.
//

import Foundation
import UIKit
import nfcComponent

class CustomThemeNfc: ThemeNFCProtocol {
    var name: String {
        "custom"
    }
    var images: [R.Image: UIImage?] = [:]
    
    var colors: [R.Color: UIColor?] = [
        R.Color.sdkPrimaryColor: UIColor.red,
        R.Color.sdkTitleTextColor: UIColor.cyan,
        R.Color.sdkBodyTextColor: UIColor.systemPink,
        R.Color.sdkSecondaryColor: UIColor.green,
        R.Color.sdkTopIconsColor: UIColor.orange
    ]

    var fonts: [R.Font: String] = [
        R.Font.regular: "HelveticaNeue-UltraLight"
    ]

    var dimensions: [R.Dimension: CGFloat] = [
        R.Dimension.fontBig: 40.0,
        R.Dimension.radiusCorner: 0.0
    ]
}
