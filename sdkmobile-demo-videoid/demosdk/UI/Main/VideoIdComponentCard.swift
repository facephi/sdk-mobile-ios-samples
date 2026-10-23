//
//  VideoIdComponentCard.swift
//  demosdk
//
//  SwiftUI port of Android ui/composables/BaseComponentCard.kt (DemoVideoId).
//

import SwiftUI

struct VideoIdComponentCard: View {
    let enabled: Bool
    let title: String
    let desc: String
    let buttonText: String
    let result: UIComponentResult
    let onLaunch: (_ autoFace: Bool) -> Void

    @State private var autoFace = true

    var body: some View {
        DemoCard(title: title, desc: desc) {
            HStack {
                BaseCheckView(text: "onboarding_show_auto_face".localized, isOn: $autoFace)
                    .fixedSize(horizontal: true, vertical: false)
                Spacer(minLength: 0)
            }
            .opacity(enabled ? 1 : 0.6)

            BaseButton(text: buttonText, enabled: enabled) {
                onLaunch(autoFace)
            }

            ResultRow(result: result)
        }
    }
}
