//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 25.08.2026.
//

import Foundation
import OSLog

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let oauthTokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {}

    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            Logger.auth.warning(
                "Попытка повторного запроса токена с тем же кодом авторизации заблокирована"
            )
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            Logger.logError(
                category: .auth,
                "RequestCreationError - не удалось создать URLRequest для кода: \(code)"
            )
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self else { return }

            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let decoded):
                    let accessToken = decoded.accessToken
                    self.oauthTokenStorage.token = accessToken

                    Logger.auth.info(
                        "Токен авторизации успешно получен от Unsplash API"
                    )
                    completion(.success(accessToken))
                case .failure(let error):
                    Logger.logError(
                        category: .auth,
                        "NetworkError - не удалось получить токен",
                        error: error
                    )
                    completion(.failure(error))
                }
                self.task = nil
                self.lastCode = nil
            }
        }

        self.task = task
        task.resume()
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard
            var urlComponents = URLComponents(
                string: Constants.URL.token
            )
        else {
            Logger.logError(
                category: .auth,
                "URLComponentsError - не удалось создать компоненты из базовой строки"
            )
            assertionFailure("Failed to create URLComponents")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let url = urlComponents.url else {
            Logger.logError(
                category: .auth,
                "URLError - не удалось сформировать итоговый URL с параметрами"
            )
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue

        return request
    }
}
