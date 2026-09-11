//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 04.09.2026.
//

import Foundation

struct ProfileResult: Codable {
    let username: String
    let firstName: String
    let lastName: String
    let bio: String?

    private enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
}

struct Profile {
    let username: String
    let name: String
    let bio: String?

    var loginName: String {
        "@\(username)"
    }
}

final class ProfileService {
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profile: Profile?

    private init() {}

    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    ) {
        task?.cancel()
        guard let request = makeProfileRequest(token) else {
            return
        }

        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let profileResult = try decoder.decode(
                        ProfileResult.self,
                        from: data
                    )
                    let profile = Profile(
                        username: profileResult.username,
                        name:
                            "\(profileResult.firstName) \(profileResult.lastName)",
                        bio: profileResult.bio
                    )
                    self.profile = profile
                    completion(.success(profile))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
            self.task = nil

        }
        self.task = task
        task.resume()

    }

    private func makeProfileRequest(_ authToken: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/me")
        else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(authToken)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }
}
