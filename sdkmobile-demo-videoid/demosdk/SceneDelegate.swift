//
//  SceneDelegate.swift
//  demosdk
//

import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        DemoFont.register()

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIHostingController(rootView: MainScreen())
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Same as Android MainActivity.onDestroy
        SDKManager.shared.closeSession()
    }
}
