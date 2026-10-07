//
//  Photo.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 07.10.2026.
//

import Foundation

struct Photo: Codable {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
