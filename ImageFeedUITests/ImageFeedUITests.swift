//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Eduard Ptushko on 13.10.2026.
//

import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        print(app.debugDescription)

        app.buttons["Authenticate"].tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10))

        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField)
            .element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 2))

        passwordTextField.tap()
        passwordTextField.typeText("")
        passwordTextField.swipeUp()

        webView.buttons["Login"].tap()

        sleep(5)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }

    func testFeed() throws {
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()

        sleep(2)

        let cellToLike = tablesQuery.children(matching: .cell).element(
            boundBy: 1
        )

        let likeButton = cellToLike.buttons["likeButton"]

        likeButton.tap()
        likeButton.tap()
        
        sleep(2)
        cellToLike.tap()
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let navButtonBack = app.buttons["backButtonWhite"]
        navButtonBack.tap()
    }

    func testProfile() throws {
        sleep(3)
        let tabBar = app.tabBars.buttons.element(boundBy: 1)
        tabBar.tap()

        XCTAssertTrue(app.staticTexts[""].exists)
        XCTAssertTrue(app.staticTexts[""].exists)

        let logoutButton = app.buttons["logoutButton"]
        logoutButton.tap()

        app.alerts["Alert"].scrollViews.otherElements.buttons["Да"].tap()

        sleep(2)
        XCTAssertTrue(app.staticTexts["Войти"].exists)
    }

}
