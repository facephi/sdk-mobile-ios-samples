//
//  CustomThemeSelphID.swift
//  demosdk
//
//  Created by Jorge Poveda on 25/9/24.
//

import selphidComponent
import UIKit
import Foundation

class CustomThemeSelphID: ThemeSelphidProtocol {
    var name: String = "custom"
    
    var fonts: [selphidComponent.R.Font : String] = [:]
    
    var dimensions: [selphidComponent.R.Dimension : CGFloat] = [:]
    
    var animations: [selphidComponent.R.Animation : String] {
        [.selphid_anim_tuto_id_1: "animation_step_id_card_first",
         .selphid_anim_tuto_id_2: "animation_step_id_card_second",
         .selphid_anim_tuto_id_3: "animation_step_id_card_third"]
    }
}
