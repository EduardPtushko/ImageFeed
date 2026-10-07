//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 01.10.2026.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let width: Int
    let height: Int
    let likedByUser: Bool
    let description: String?
    let createdAt: String
    let urls: UrlsResult

    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case likedByUser = "liked_by_user"
        case description
        case createdAt = "created_at"
        case urls
    }

    struct UrlsResult: Codable {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }
}

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
