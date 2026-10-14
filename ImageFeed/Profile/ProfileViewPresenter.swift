//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 09.10.2026.
//

import Foundation
import OSLog

protocol ProfileViewPresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func didTapLogout()
    func didConfirmLogout()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {

    // MARK: - Private Properties

    private let profileService: ProfileServiceProtocol
    private let profileLogoutService: ProfileLogoutServiceProtocol
    private var profileImageServiceObserver: NSObjectProtocol?

    weak var view: ProfileViewControllerProtocol?

    init(
        profileService: ProfileServiceProtocol = ProfileService.shared,
        profileLogoutService: ProfileLogoutServiceProtocol =
            ProfileLogoutService.shared
    ) {
        self.profileService = profileService
        self.profileLogoutService = profileLogoutService
    }

    func viewDidLoad() {
        if let profile = profileService.profile {
            provideProfileDetails(profile)
        }

        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self else { return }
                self.provideAvatarURL()
            }

        provideAvatarURL()
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    func didTapLogout() {
        view?.showConfirmLogout()
    }

    func didConfirmLogout() {
        profileLogoutService.logout()
        view?.navigateToSplashView()
    }

    // MARK: - Private Methods

    private func provideProfileDetails(_ profile: Profile) {
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let login =
            profile.username.isEmpty
            ? "@неизвестный пользователь" : profile.loginName
        let bio =
            (profile.bio?.isEmpty ?? true)
            ? "Профиль не заполнен" : (profile.bio ?? "")

        view?.updateProfileDetails(name: name, login: login, bio: bio)
    }

    private func provideAvatarURL() {
        if let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        {
            view?.updateAvatar(with: url)
        } else {
            view?.updateAvatar(with: nil)
        }
    }

}
