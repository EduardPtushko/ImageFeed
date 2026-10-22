//
//  ProfileViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 09.10.2026.
//

import Foundation

@testable import ImageFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfileViewPresenterProtocol?

    var showConfirmLogoutCalled = false
    var navigateToSplashViewCalled = false

    var updateProfileDetailsCalled = false
    var passedName: String?
    var passedLogin: String?
    var passedBio: String?

    func showConfirmLogout() {
        showConfirmLogoutCalled = true
    }

    func navigateToSplashView() {
        navigateToSplashViewCalled = true
    }

    func updateAvatar(with url: URL?) {

    }

    func updateProfileDetails(name: String, login: String, bio: String) {
        updateProfileDetailsCalled = true
        passedName = name
        passedLogin = login
        passedBio = bio
    }
}
