//
//  ProfileViewTests.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 09.10.2026.
//

import XCTest

@testable import ImageFeed

final class ProfileViewTests: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenterSpy = ProfileViewPresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController

        viewController.loadViewIfNeeded()

        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testPresenterDidTapLogout() {
        let presenter = ProfileViewPresenter()
        let viewControllerSpy = ProfileViewControllerSpy()
        presenter.view = viewControllerSpy
        viewControllerSpy.presenter = presenter

        presenter.didTapLogout()

        XCTAssertTrue(viewControllerSpy.showConfirmLogoutCalled)
        XCTAssertFalse(viewControllerSpy.navigateToSplashViewCalled)
    }

    func testViewControllerCallsDidTapLogoutOnPresenter() {
        let viewController = ProfileViewController()
        let presenterSpy = ProfileViewPresenterSpy()
        viewController.presenter = presenterSpy
        _ = viewController.view

        viewController.perform(
            #selector(ProfileViewController.didTapLogoutButton)
        )

        XCTAssertTrue(presenterSpy.didTapLogoutCalled)
    }

    func testViewDidLoadProvidesDefaultStringsWhenProfileIsEmpty() {
        let profileService = ProfileServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileService)
        let viewControllerSpy = ProfileViewControllerSpy()
        presenter.view = viewControllerSpy
        viewControllerSpy.presenter = presenter
        profileService.profile = Profile(username: "", name: "", bio: "")

        presenter.viewDidLoad()

        XCTAssertTrue(viewControllerSpy.updateProfileDetailsCalled)
        XCTAssertEqual(viewControllerSpy.passedName, "Имя не указано")
        XCTAssertEqual(
            viewControllerSpy.passedLogin,
            "@неизвестный пользователь"
        )
        XCTAssertEqual(viewControllerSpy.passedBio, "Профиль не заполнен")
    }

    func testViewDidLoadProvidesCorrectProfileDetails() {
        let profileService = ProfileServiceStub()
        let presenter = ProfileViewPresenter(profileService: profileService)
        let viewControllerSpy = ProfileViewControllerSpy()
        presenter.view = viewControllerSpy
        viewControllerSpy.presenter = presenter
        profileService.profile = Profile(
            username: "johndoe",
            name: "John Doe",
            bio: "iOS Dev"
        )

        presenter.viewDidLoad()

        XCTAssertTrue(viewControllerSpy.updateProfileDetailsCalled)
        XCTAssertEqual(viewControllerSpy.passedName, "John Doe")
        XCTAssertEqual(
            viewControllerSpy.passedLogin,
            "@johndoe"
        )
        XCTAssertEqual(viewControllerSpy.passedBio, "iOS Dev")
    }

    func testDidConfirmLogoutTriggersServiceAndNavigation() {
        let profileLogoutService = ProfileLogoutServiceSpy()
        let presenter = ProfileViewPresenter(
            profileLogoutService: profileLogoutService
        )
        let viewControllerSpy = ProfileViewControllerSpy()
        presenter.view = viewControllerSpy
        viewControllerSpy.presenter = presenter

        presenter.didConfirmLogout()

        XCTAssertTrue(profileLogoutService.logoutCalled)
        XCTAssertTrue(viewControllerSpy.navigateToSplashViewCalled)
    }

}
