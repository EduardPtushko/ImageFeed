//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 11.09.2026.
//

import Foundation


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

final class ProfileImageService {
    static let shared = ProfileImageService()
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = storage.token else {
            return
        }
        
        guard let request = makeProfileImageRequest(username: username, token: token) else {
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    
                    let userResult = try decoder.decode(UserResult.self, from: data)
                    let smallImage = userResult.profileImage.small
                    self.avatarURL = smallImage
                     
                    completion(.success(smallImage))
                    
                    NotificationCenter.default
                        .post(name: ProfileImageService.didChangeNotification, object: self, userInfo: ["URL": smallImage])
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
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)/users/\(username)") else {
            return nil
        }
       
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)",
                         forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    
    
}
