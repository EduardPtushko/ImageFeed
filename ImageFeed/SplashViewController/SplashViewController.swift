//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 28.08.2026.
//

import OSLog
import UIKit

// MARK: - SplashViewController

final class SplashViewController: UIViewController {

    // MARK: - Private Properties

    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared

    private lazy var splashScreenImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(resource: .splashScreenLogo)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(splashScreenImageView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            splashScreenImageView.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            splashScreenImageView.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
        ])
    }

}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }

            if let token = self.storage.token {
                self.fetchProfile(token: token)
            } else {
                Logger.logError(
                    category: .network,
                    "Ошибка - Токен не найден после авторизации"
                )
            }
        }

        switchToTabBarController()
    }
}

// MARK: - Private Methods
extension SplashViewController {
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard
            let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController
        else {
            Logger
                .logError(
                    category: .ui,
                    "Не удалось найти AuthViewController в Storyboard"
                )

            assertionFailure(
                "Не удалось найти AuthViewController по идентификатору"
            )
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }

    private func switchToTabBarController() {
        DispatchQueue.main.async {
            guard let window = SceneDelegate.shared?.window
            else {
                Logger.logError(
                    category: .ui,
                    "WindowError - Не удалось найти активное keyWindow"
                )
                assertionFailure("Invalid window configuration")
                return
            }

            let tabBarController = TabBarController()
            window.rootViewController = tabBarController
        }
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(
                    username: profile.username
                ) { _ in }
                self.switchToTabBarController()
            case .failure(let error):
                Logger.logError(
                    category: .network,
                    "Не удалось получить профайл",
                    error: error
                )
                self.showNetworkErrorAlert()
            }
        }
    }
    private func showNetworkErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Alert"
        let action = UIAlertAction(title: "Ок", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }
}
