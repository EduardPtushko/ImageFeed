//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 27.08.2026.
//

import Foundation
import OSLog
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(
                forKey: Keys.token.rawValue
            )

            if token != nil {
                Logger.storage.debug(
                    "Токен успешно получен из Keychain"
                )
            } else {
                Logger.storage.warning(
                    "Токен не найден в Keychain (Пользователь вероятно не авторизован)"
                )
            }

            return token
        }
        set {
            if let token = newValue {
                let isSuccess = KeychainWrapper.standard.set(
                    token,
                    forKey: Keys.token.rawValue
                )
                if isSuccess {
                    Logger.storage.info(
                        "Новый токен успешно сохранен в Keychain"
                    )
                } else {
                    Logger.logError(
                        category: .storage,
                        "Не удалось сохранить токен в Keychain"
                    )
                }
            } else {
                let isRemoved = KeychainWrapper.standard.removeObject(
                    forKey: Keys.token.rawValue
                )
                if isRemoved {
                    Logger.storage.info(
                        "Новый токен успешно удален из Keychain"
                    )
                } else {
                    Logger.logError(
                        category: .storage,
                        "Не удалось удалить токен из Keychain"
                    )
                }
            }
        }
    }
}

extension OAuth2TokenStorage {
    fileprivate enum Keys: String {
        case token = "OAuth2TokenKey"
    }
}
