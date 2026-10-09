//
//  WebViewViewControllerSpy.swift
//  ImageFeedTests
//
//  Created by Eduard Ptushko on 08.10.2026.
//

import Foundation
@testable import ImageFeed

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: (any ImageFeed.WebViewPresenterProtocol)?
    
    var wasLoadRequestCalled = false
    
    func load(request: URLRequest) {
        wasLoadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    
    func setProgressHidden(_ isHidden: Bool) {
        
    }
    
    
}
