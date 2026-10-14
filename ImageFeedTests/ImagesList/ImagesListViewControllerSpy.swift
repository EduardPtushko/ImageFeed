//
//  ImagesListViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 13.10.2026.
//

import Foundation

@testable import ImageFeed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListViewPresenterProtocol?

    var insertRowsCalled = false
    var insertRowsIndices: IndexSet?

    var showSingleViewImageCalled = false
    var lastSelectedImageURL: String?

    var showProgressHUDCalled = false
    var dismissProgressHUDCalled = false

    var updateRowCalled = false
    var lastUpdatedRowIndex: Int?

    func insertRows(at indices: IndexSet) {
        insertRowsCalled = true
        insertRowsIndices = indices
    }

    func showSingleViewImage(imageURLString: String) {
        showSingleViewImageCalled = true
        lastSelectedImageURL = imageURLString
    }

    func showProgressHUD() {
        showProgressHUDCalled = true
    }

    func dismissProgressHUD() {
        dismissProgressHUDCalled = true
    }

    func updateRow(at index: Int) {
        lastUpdatedRowIndex = index
        updateRowCalled = true
    }

}
