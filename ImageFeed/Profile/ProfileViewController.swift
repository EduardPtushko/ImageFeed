//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 06.08.2026.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(resource: .avatar)
        imageView.image = image
        imageView.translatesAutoresizingMaskIntoConstraints = false
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
    }

    // MARK: - Setup Methods

    private func setupUI() {
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
