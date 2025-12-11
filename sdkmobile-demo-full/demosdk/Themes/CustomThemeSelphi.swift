//
//  CustomThemeSelphi.swift
//  demosdk
//
//  Created by Jorge Poveda on 30/9/24.
//


import selphiComponent

class CustomThemeSelphi: ThemeSelphiProtocol {
    var name: String = "custom"
    
    var animations: [R.Animation : String] {
        [.selphi_anim_prev_tip: "custom_selphi_anim_tip",
         .selphi_anim_prev_tip_move: "custom_selphi_anim_tip_move",
         .selphi_anim_tuto_1: "custom_selphi_anim_tuto_1",
         .selphi_anim_tuto_2: "custom_selphi_anim_tuto_2",
         .selphi_anim_tuto_3: "custom_selphi_anim_tuto_3"]
    }
}
