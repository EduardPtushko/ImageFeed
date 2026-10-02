//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 11.09.2026.
//

import Foundation
import OSLog

final class ProfileImageService {

    // MARK: - Constants

    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(
        "ProfileImageProviderDidChange"
    )

    // MARK: - Private Properties

    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    private var task: URLSessionTask?

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    func fetchProfileImageURL(
        username: String,
        _ completion: @escaping (Result<String, Error>) -> Void
    ) {
        task?.cancel()

        guard let token = storage.token else {
            let tokenError = NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey: "Authorization token missing"
                ]
            )
            Logger.logError(
                category: .network,
                "AuthError - отсутствует токен авторизации для пользователя: \(username)",
                error: tokenError
            )

            completion(.failure(tokenError))
            return
        }

        guard
            let request = makeProfileImageRequest(
                username: username,
                token: token
            )
        else {
            let urlError = URLError(.badURL)
            Logger.logError(
                category: .network,
                "RequestCreationError - не удалось создать URLRequest для пользователя: \(username)",
                error: urlError
            )

            completion(.failure(urlError))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }

            switch result {
            case .success(let userResult):

                let smallImage = userResult.profileImage.small
                self.avatarURL = smallImage

                DispatchQueue.main.async {
                    completion(.success(smallImage))

                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": smallImage]
                        )
                }
            case .failure(let error):
                Logger.logError(
                    category: .network,
                    "NetworkError - \(error) для пользователя: \(username)",
                    error: error
                )
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    func clearAvatarData() {
        task?.cancel()
        task = nil
        avatarURL = nil
    }

    // MARK: - Private Methods

    private func makeProfileImageRequest(username: String, token: String)
        -> URLRequest?
    {
        guard
            let url = URL(
                string: "\(Constants.defaultBaseURLString)/users/\(username)"
            )
        else {
            Logger.logError(
                category: .network,
                "URLError - не удалось сформировать URL для строки: \(Constants.defaultBaseURLString)/users/\(username)"
            )
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }

}
