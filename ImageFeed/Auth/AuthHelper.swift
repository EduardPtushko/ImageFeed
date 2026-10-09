//
//  AuthHelper.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 07.10.2026.
//

import Foundation
import OSLog

protocol AuthHelperProtocol {
    func authRequest() -> URLRequest?
    func code(from url: URL) -> String?
}

final class AuthHelper: AuthHelperProtocol {
    let configuration: AuthConfiguration

    init(configuration: AuthConfiguration = .standard) {
        self.configuration = configuration
    }

    func authRequest() -> URLRequest? {
        guard let url = authURL() else {
            Logger.logError(
                category: .network,
                "URLError - не удалось сформировать итоговый URL с параметрами"
            )
            return nil
        }

        return URLRequest(url: url)
    }

    func code(from url: URL) -> String? {
        if let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code" })
        {
            return codeItem.value
        } else {
            return nil
        }
    }

    func authURL() -> URL? {
        guard
            var urlComponents = URLComponents(
                string: configuration.authURLSting
            )
        else {
            Logger.logError(
                category: .network,
                "URLComponentsError - не удалось создать компоненты из базовой строки"
            )
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: configuration.accessKey),
            URLQueryItem(
                name: "redirect_uri",
                value: configuration.redirectURI
            ),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: configuration.accessScope),
        ]

        return urlComponents.url
    }

}
