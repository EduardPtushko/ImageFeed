//
//  Profile.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 07.10.2026.
//

import Foundation

struct Profile {
    let username: String
    let name: String
    let bio: String?

    var loginName: String {
        "@\(username)"
    }
}
