//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 04.09.2026.
//

import Foundation
import OSLog

final class ProfileService {

    static let shared = ProfileService()

    // MARK: - Private Properties

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?

    // MARK: - Init

    private init() {}

    // MARK: - Private Methods

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        task?.cancel()
        guard let request = makeProfileRequest(token) else {
            let urlError = URLError(.badURL)
            
            Logger.logError(
                category: .network,
                "RequestCreationError - не удалось создать URLRequest",
                error: urlError
            )

            completion(.failure(urlError))
            return
        }

        let task = urlSession.objectTask(for: request) {
            [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }

            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username,
                    name:
                        "\(profileResult.firstName) \(profileResult.lastName)",
                    bio: profileResult.bio
                )
                self.profile = profile
                completion(.success(profile))

            case .failure(let error):
                Logger.logError(category: .network, "NetworkError - Ошибка при получении профайла: ", error: error)
                completion(.failure(error))
            }
            self.task = nil

        }
        self.task = task
        task.resume()

    }

    func clearProfileData() {
        task?.cancel()
        task = nil
        profile = nil
    }

    // MARK: - Private Methods

    private func makeProfileRequest(_ authToken: String) -> URLRequest? {
        let urlString = "\(Constants.defaultBaseURLString)/me"
        
        guard let url = URL(string: urlString)
        else {
            Logger
                .logError(
                    category: .network,
                    "URLError - не удалось сформировать URL из строки: \(urlString)"
                )
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue(
            "Bearer \(authToken)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }

}
