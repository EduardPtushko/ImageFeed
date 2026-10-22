//
//  ProfileViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 09.10.2026.
//

import Foundation

@testable import ImageFeed

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {

    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false

    var didConfirmLogoutCalled = false
    var didTapLogoutCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func didTapLogout() {
        didTapLogoutCalled = true
    }

    func didConfirmLogout() {
        didConfirmLogoutCalled = true
    }

}
