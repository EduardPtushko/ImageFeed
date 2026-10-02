//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 02.10.2026.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let bio: String?

    var loginName: String {
        "@\(username)"
    }
}
