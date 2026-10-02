//
//  Logger+Extensions.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 01.10.2026.
//

import Foundation
import OSLog

extension Logger {
    private static var subsystem =
        Bundle.main.bundleIdentifier ?? "com.ImageFeed"

    static let network = Logger(subsystem: subsystem, category: "Network")
    static let ui = Logger(subsystem: subsystem, category: "UI")
    static let auth = Logger(subsystem: subsystem, category: "Auth")

    static let profile = Logger(subsystem: subsystem, category: "Profile")
    static let storage = Logger(subsystem: subsystem, category: "Storage")
    static let images = Logger(subsystem: subsystem, category: "Images")

    static func logError(
        category: Logger,
        _ message: String,
        error: Error? = nil,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let fileName = (file as NSString).lastPathComponent

        var fullMessage =
            "❌ [\(fileName) -> \(function) : Line \(line)] \(message)"
        if let error = error {
            fullMessage += " | Details: \(error.localizedDescription)"
        }

        category.error("\(fullMessage, privacy: .public)")
    }
}
