//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 11.09.2026.
//

import Foundation

final class ProfileImageService {

    struct ProfileImage: Codable {
        let small: String
        let medium: String
        let large: String
    }

    struct UserResult: Codable {
        let profileImage: ProfileImage

        private enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
    }

    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange"
    )
    private let storage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    private var task: URLSessionTask?

    private init() {}

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
            print(
                "[ProfileImageService.fetchProfileImageURL]: AuthError - отсутствует токен авторизации для пользователя: \(username)"
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
            print(
                "[ProfileImageService.fetchProfileImageURL]: RequestCreationError - не удалось создать URLRequest для пользователя: \(username)"
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
                print(
                    "[ProfileImageService.fetchProfileImageURL]: NetworkError - \(error) для пользователя: \(username)"
                )
                completion(.failure(error))
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(username: String, token: String)
        -> URLRequest?
    {
        guard
            let url = URL(
                string: "\(Constants.defaultBaseURLString)/users/\(username)"
            )
        else {
            print(
                "[ProfileImageService.makeProfileImageRequest]: URLError - не удалось сформировать URL для строки: \(Constants.defaultBaseURLString)/users/\(username)"
            )
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }

}
