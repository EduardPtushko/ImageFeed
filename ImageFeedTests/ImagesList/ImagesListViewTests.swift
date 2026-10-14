//
//  ImagesListViewTests.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 13.10.2026.
//

import XCTest

@testable import ImageFeed

final class ImagesListViewTests: XCTestCase {
    var sut: ImagesListViewController!
    var presenterSpy: ImagesListViewPresenterSpy!

    override func setUp() {
        super.setUp()

        sut = ImagesListViewController()
        presenterSpy = ImagesListViewPresenterSpy()
        presenterSpy.view = sut
        sut.presenter = presenterSpy
    }

    override func tearDown() {
        sut = nil
        presenterSpy = nil
        super.tearDown()
    }

    func testViewControllerCallsViewDidLoad() {

        sut.loadViewIfNeeded()

        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testTableViewNumberOfRows() {
        presenterSpy.mockPhotosCount = 5

        sut.loadViewIfNeeded()

        let tableView = sut.tableView
        let rowsCount = sut.tableView(
            tableView,
            numberOfRowsInSection: 0
        )

        XCTAssertTrue(presenterSpy.photosCountCalled)
        XCTAssertEqual(rowsCount, 5)
    }

    func testTableViewDidSelectRowAt() {

        sut.loadViewIfNeeded()

        let indexPath = IndexPath(row: 1, section: 0)
        let tableView = sut.tableView
        sut.tableView(
            tableView,
            didSelectRowAt: indexPath
        )

        XCTAssertTrue(presenterSpy.didTapOnTableRowCalled)
        XCTAssertEqual(presenterSpy.didTapOnTableRowIndexRow, 1)
    }

    func testTableViewHeightForRowAt() {
        presenterSpy.mockRowHeight = 250

        sut.loadViewIfNeeded()

        let tableView = sut.tableView
        let indexPath = IndexPath(row: 0, section: 0)
        let height = sut.tableView(tableView, heightForRowAt: indexPath)

        XCTAssertTrue(presenterSpy.calculateHeightForRowCalled)
        XCTAssertEqual(height, 250)
    }

    func testTableViewWillDisplayCell() {
        sut.loadViewIfNeeded()

        let dummyCell = ImagesListCell()
        let indexPath = IndexPath(row: 9, section: 0)
        let tableView = sut.tableView
        sut.tableView(
            tableView,
            willDisplay: dummyCell,
            forRowAt: indexPath
        )

        XCTAssertTrue(presenterSpy.willDisplayCellCalled)
        XCTAssertEqual(presenterSpy.lastDisplayedCellIndex, 9)
    }

    func testPresenterInitialPhotosCountIsZero() {
        let viewControllerSpy = ImagesListViewControllerSpy()
        let presenter = ImagesListViewPresenter()
        presenter.view = viewControllerSpy
        viewControllerSpy.presenter = presenter

        let count = presenter.photosCount()

        XCTAssertEqual(
            count,
            0,
            "На старте количество фотографий в презентере должно быть равно 0"
        )
    }

}
