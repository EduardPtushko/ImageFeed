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

    enum URL {
        static let defaultBaseURLString = "https://api.unsplash.com"
        static let authorize = "https://unsplash.com/oauth/authorize"
        static let token = "https://unsplash.com/oauth/token"
        static let photos = "https://api.unsplash.com/photos"
    }
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    
    let defaultBaseURLString: String
    let authURLSting: String
    let tokenURLSting: String
    let photosURLSting: String
    
    init(
        accessKey: String,
        secretKey: String,
        redirectURI: String,
        accessScope: String,
        defaultBaseURLString: String,
        authURLString: String,
        tokenURLSting: String,
        photosURLSting: String
    ) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLSting = authURLString
        self.tokenURLSting = tokenURLSting
        self.photosURLSting = photosURLSting
    }
    
    static var standard: AuthConfiguration {
        AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaultBaseURLString: Constants.URL.defaultBaseURLString,
            authURLString: Constants.URL.authorize,
            tokenURLSting: Constants.URL.token,
            photosURLSting: Constants.URL.photos
        )
    }
    
}
