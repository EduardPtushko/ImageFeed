//
//  ProfileServiceSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 14.10.2026.
//

import Foundation

@testable import ImageFeed

final class ProfileServiceStub: ProfileServiceProtocol {
    var profile: Profile?
}

final class ProfileLogoutServiceSpy: ProfileLogoutServiceProtocol {
    var logoutCalled = false

    func logout() {
        logoutCalled = true
    }
}
