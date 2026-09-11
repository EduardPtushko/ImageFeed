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
    private let oauthTokenStorage = OAuth2TokenStorage()
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
            print("Failed to create OAuthTokenRequest")
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let accessToken = try decoder.decode(
                            OAuthTokenResponseBody.self,
                            from: data
                        ).accessToken

                        self.oauthTokenStorage.token = accessToken
                        completion(.success(accessToken))
                    } catch {
                        print(error.localizedDescription)
                        completion(.failure(NetworkError.decodingError(error)))
                    }

                case .failure(let error):
                    print(error.localizedDescription)
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
            print("Failed to create URLComponents")
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
            print("Failed to create URL")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return request
    }
}
