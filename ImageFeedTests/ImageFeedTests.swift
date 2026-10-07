//
//  ImageFeedTests.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 21.09.2026.
//

@testable import ImageFeed
import XCTest

final class ImagesListServiceTests: XCTestCase {
    func testFetchPhotos() {
        let service = ImagesListService.shared
        
        let expectation = self.expectation(description: "Wait for Notification")
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
           
        ) { _ in
            expectation.fulfill()
        }
        
        service.fetchPhotosNextPage { _ in
            
        }
        wait(for: [expectation], timeout: 10)
        
        XCTAssertEqual(service.photos.count, 10)
    }
}
