//
//  CustomThemeSelphID.swift
//  demosdk
//
//  Created by Jorge Poveda on 25/9/24.
//

import selphidComponent
class CustomThemeSelphID: ThemeSelphidProtocol {
    var name: String = "custom"
    
    var animations: [selphidComponent.R.Animation : String] {
        [.selphid_anim_tuto_id_1: "animation_step_id_card_first",
         .selphid_anim_tuto_id_2: "animation_step_id_card_second",
         .selphid_anim_tuto_id_3: "animation_step_id_card_third"]
    }
}
