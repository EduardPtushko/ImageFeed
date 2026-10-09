//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 06.08.2026.
//

import Kingfisher
import OSLog
import UIKit

protocol ProfileViewControllerProtocol: AnyObject {
    var presenter: ProfileViewPresenterProtocol? { get set }
    func showConfirmLogout()
    func navigateToSplashView()
    func updateAvatar(with url: URL?)
    func updateProfileDetails(name: String, login: String, bio: String)
}

final class ProfileViewController: UIViewController
        & ProfileViewControllerProtocol
{
    var presenter: (any ProfileViewPresenterProtocol)?

    // MARK: - UI Elements

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(
                UIImage.SymbolConfiguration(
                    pointSize: 70,
                    weight: .regular,
                    scale: .large
                )
            )
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(resource: .logoutButton), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(didTapLogoutButton),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Екатерина Новикова"
        label.textColor = .ypWhite
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()

    private lazy var loginNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "@ekaterina_nov"
        label.textColor = .ypGrey
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hello, World!"
        label.textColor = .ypWhite
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        presenter?.viewDidLoad()

    }

    // MARK: - Setup Methods

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        [
            avatarImageView, logoutButton, nameLabel, loginNameLabel,
            descriptionLabel,
        ].forEach {
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            avatarImageView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 32
            ),
            avatarImageView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),

            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
            logoutButton.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                constant: -16
            ),
            logoutButton.centerYAnchor.constraint(
                equalTo: avatarImageView.centerYAnchor
            ),

            nameLabel.topAnchor.constraint(
                equalTo: avatarImageView.bottomAnchor,
                constant: 8
            ),
            nameLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.leadingAnchor
            ),

            loginNameLabel.topAnchor.constraint(
                equalTo: nameLabel.bottomAnchor,
                constant: 8
            ),
            loginNameLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.leadingAnchor
            ),

            descriptionLabel.topAnchor.constraint(
                equalTo: loginNameLabel.bottomAnchor,
                constant: 8
            ),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: avatarImageView.leadingAnchor
            ),
        ])
    }

    // MARK: - Actions

    @objc private func didTapLogoutButton() {
        presenter?.didTapLogout()
    }
}

// MARK: - Public Methods

extension ProfileViewController {
    func updateAvatar(with url: URL?) {

        let profileImagePlaceholder = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(
                UIImage.SymbolConfiguration(
                    pointSize: 70,
                    weight: .regular,
                    scale: .large
                )
            )

        guard let url else {
            avatarImageView.image = profileImagePlaceholder
            return
        }

        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: profileImagePlaceholder,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
            ]
        ) { result in
            switch result {
            case .success(let value):
                Logger.profile.debug(
                    "Success - Аватар загружен из источника: \(String(describing: value.source)) для URL: \(url)"
                )
            case .failure(let error):
                Logger.logError(
                    category: .profile,
                    "KingfisherError - \(error.localizedDescription) для URL: \(url)",
                    error: error
                )
            }
        }
    }

    func updateProfileDetails(name: String, login: String, bio: String) {
        nameLabel.text = name
        loginNameLabel.text = login
        descriptionLabel.text = bio
    }

    func navigateToSplashView() {
        let splashViewController = SplashViewController()

        let keyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }

        if let window = keyWindow {
            window.rootViewController = splashViewController
            UIView.transition(
                with: window,
                duration: 0.3,
                options: .transitionCrossDissolve,
                animations: nil,
                completion: nil
            )
        }
    }

    func showConfirmLogout() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Alert"

        let logoutAction = UIAlertAction(title: "Да", style: .default) {
            [weak self] _ in
            guard let self else { return }

            self.presenter?.didConfirmLogout()
        }
        let cancelAction = UIAlertAction(title: "Нет", style: .default)

        alert.addAction(logoutAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
