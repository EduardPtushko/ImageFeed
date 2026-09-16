//
//  ViewControllerPreview.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 16.09.2026.
//


#if DEBUG
import SwiftUI

struct ViewControllerPreview<Controller: UIViewController>: UIViewControllerRepresentable {
    private let builder: () -> Controller
    
    init(_ builder: @escaping () -> Controller) {
        self.builder = builder
    }
    
    func makeUIViewController(context: Context) -> Controller {
        builder()
    }
    
    func updateUIViewController(_ uiViewController: Controller, context: Context) {}
}
#endif
