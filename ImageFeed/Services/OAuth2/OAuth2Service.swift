//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 25.08.2026.
//

import Foundation

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
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            print(
                "[OAuth2Service.fetchOAuthToken]: RequestCreationError - не удалось создать URLRequest для кода: \(code)"
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
                    completion(.success(accessToken))
                case .failure(let error):
                    print(
                        "[OAuth2Service]: NetworkError - не удалось получить токен. Ошибка: \(error)"
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
            print(
                "[OAuth2Service.makeOAuthTokenRequest]: URLComponentsError - не удалось создать компоненты из базовой строки"
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
            print(
                "[OAuth2Service.makeOAuthTokenRequest]: URLError - не удалось сформировать итоговый URL с параметрами"
            )
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }
}
