//
//  ImagesListViewPresenterSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 13.10.2026.
//

import Foundation

@testable import ImageFeed

final class ImagesListViewPresenterSpy: ImagesListViewPresenterProtocol {
    var view: (any ImageFeed.ImagesListViewControllerProtocol)?

    var viewDidLoadCalled = false
    var photosCountCalled = false

    var didTapOnTableRowCalled = false
    var didTapOnTableRowIndexRow: Int?

    var calculateHeightForRowCalled = false

    var willDisplayCellCalled = false
    var lastDisplayedCellIndex: Int?

    var configureCellCalled = false
    var lastConfiguredCellIndex: Int?

    var didTapCellLikeCalled = false
    var lastLikedCellIndex: Int?

    var mockPhotosCount = 0
    var mockRowHeight: CGFloat = 100.0

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func photosCount() -> Int {
        photosCountCalled = true
        return mockPhotosCount
    }

    func didTapOnTableRow(at indexRow: Int) {
        didTapOnTableRowCalled = true
        didTapOnTableRowIndexRow = indexRow
    }

    func calculateHeightForRow(at index: Int, tableViewWidth: CGFloat)
        -> CGFloat
    {
        calculateHeightForRowCalled = true
        return mockRowHeight
    }

    func willDisplayCell(indexRow: Int) {
        willDisplayCellCalled = true
        lastDisplayedCellIndex = indexRow
    }

    func configureCell(
        _ cell: ImagesListCellProtocol,
        at index: Int
    ) {
        configureCellCalled = true
        lastConfiguredCellIndex = index
    }

    func didTapCellLike(index: Int) {
        didTapCellLikeCalled = true
        lastLikedCellIndex = index
    }

}
