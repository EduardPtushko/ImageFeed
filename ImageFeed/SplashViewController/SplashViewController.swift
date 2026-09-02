//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 28.08.2026.
//

import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier =
        "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if storage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(
                withIdentifier: showAuthenticationScreenSegueIdentifier,
                sender: nil
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    private func switchToTabBarController() {
        guard
            let window = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .filter({ $0.activationState == .foregroundActive }).first?.keyWindow
        else {
            assertionFailure("Invalid window configuration")
            return
        }

        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(
                identifier: "TabBarViewController"
            )
        window.rootViewController = tabBarController
    }
}

// MARK: - Navigation

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination
                    as? UINavigationController,
                let viewController = navigationController.viewControllers.first
                    as? AuthViewController
            else {
                assertionFailure(
                    "Failed to prepare for \(showAuthenticationScreenSegueIdentifier)"
                )
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            self?.switchToTabBarController()
        }
    }
}
