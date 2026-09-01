//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 27.08.2026.
//

import Foundation

final class OAuth2TokenStorage {
    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {
        self.storage = storage
    }

    var token: String? {
        get {
            return storage.string(forKey: Keys.token.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.token.rawValue)
        }
    }
}

private extension OAuth2TokenStorage {
   enum Keys: String {
        case token = "OAuth2TokenKey"
    }
}
