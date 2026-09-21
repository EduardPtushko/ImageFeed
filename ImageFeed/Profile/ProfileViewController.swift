//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 06.08.2026.
//

import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {

    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

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

        guard let profile = profileService.profile else { return }
        updateProfileDetails(with: profile)

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func updateAvatar() {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }

        let profileImagePlaceholder = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(
                UIImage.SymbolConfiguration(
                    pointSize: 70,
                    weight: .regular,
                    scale: .large
                )
            )

        let processor = RoundCornerImageProcessor(cornerRadius: 35)

        avatarImageView.kf.indicatorType = .activity
        avatarImageView.kf.setImage(
            with: url,
            placeholder: profileImagePlaceholder,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage, .forceRefresh,
            ]
        ) { result in
            switch result {
            case .success(let value):
                print(
                    "[ProfileViewController.updateAvatar]: Success - Аватар загружен из источника: \(value.source) для URL: \(url)"
                )
            case .failure(let error):
                print(
                    "[ProfileViewController.updateAvatar]: KingfisherError - \(error.localizedDescription) для URL: \(url)"
                )
            }
        }
    }

    private func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        loginNameLabel.text =
            profile.loginName.isEmpty
            ? "@неизвестный пользователь" : profile.loginName
        descriptionLabel.text =
            (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
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
    }
}
