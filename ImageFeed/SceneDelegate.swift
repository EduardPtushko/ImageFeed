//
//  SceneDelegate.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 24.07.2026.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    static var shared: SceneDelegate? {
            return UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        }

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = SplashViewController()
        window?.makeKeyAndVisible()
    }

}
