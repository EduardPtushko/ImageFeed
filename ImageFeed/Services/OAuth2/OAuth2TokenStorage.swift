//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 27.08.2026.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            } else {
                KeychainWrapper.standard.removeObject(
                    forKey: Keys.token.rawValue
                )
            }
        }
    }
}

extension OAuth2TokenStorage {
    fileprivate enum Keys: String {
        case token = "OAuth2TokenKey"
    }
}
