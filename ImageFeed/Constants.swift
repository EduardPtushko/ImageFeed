//
//  Constants.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 17.08.2026.
//

import Foundation

enum Constants {
    static let accessKey = "RN9uuDLuUatoXhP8IKtulTB52ZkFcPAH8TSOpnjxClo"
    static let secretKey = "Q5sTzazlZaR02aoj7LF2OYB8Brbdv1dmBcUDW-BR9fE"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURLString = "https://api.unsplash.com"

    enum URL {
        static let authorize = "https://unsplash.com/oauth/authorize"
        static let token = "https://unsplash.com/oauth/token"
    }
}
