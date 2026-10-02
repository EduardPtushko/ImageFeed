//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 24.08.2026.
//

import OSLog
import ProgressHUD
import UIKit

// MARK: - AuthViewControllerDelegate

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

// MARK: - AuthViewController

final class AuthViewController: UIViewController {
    private let showWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackButton()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewSegueIdentifier {
            guard
                let viewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(
            resource: .navBackButton
        )
        navigationController?.navigationBar.backIndicatorTransitionMaskImage =
            UIImage(resource: .navBackButton)
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.backBarButtonItem?.tintColor = UIColor(
            resource: .ypBlack
        )
    }
}

// MARK: - WebViewViewControllerDelegate

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        vc.dismiss(animated: true)
        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self else { return }

            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
            case .failure(let error):
                Logger.logError(
                    category: .network,
                    "[AuthViewController.webViewViewController]: NetworkError - Ошибка при обработке кода авторизации: \(code)",
                    error: error
                )
                self.showNetworkErrorAlert()
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}

extension AuthViewController {
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
