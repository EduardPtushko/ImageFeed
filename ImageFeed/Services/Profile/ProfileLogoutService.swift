//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 30.09.2026.
//

import Foundation
import Kingfisher
import OSLog
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout() {
        cleanCookies()

        OAuth2TokenStorage.shared.token = nil

        ProfileService.shared.clearProfileData()
        Logger.profile.info("Данные профиля успешно удалены")

        ImagesListService.shared.clearImageListServiceData()
        Logger.images.info(
            "Массив фотографий и состояние пагинации успешно сброшены"
        )

        ImageCache.default.clearMemoryCache()
        ImageCache.default.clearDiskCache()
        Logger.images.info(
            "Кэш изображений Kingfisher (в памяти и на диске) успешно очищен"
        )
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)

        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            if records.isEmpty {
                Logger.storage.debug(
                    "Записей данных WKWebsiteDataStore не обнаружено"
                )
            }
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(
                    ofTypes: record.dataTypes,
                    for: [record]
                ) {
                    Logger.storage.debug(
                        "Удалены данные для домена: \(record.displayName)"
                    )
                }
            }
        }
    }

}
