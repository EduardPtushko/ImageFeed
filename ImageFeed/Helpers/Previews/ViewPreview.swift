//
//  ViewPreview.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 16.09.2026.
//


#if DEBUG
import SwiftUI


struct ViewPreview<V: UIView>: UIViewRepresentable {
    private let builder: () -> V
    
    init(_ builder: @escaping () -> V) {
        self.builder = builder
    }
    
    func makeUIView(context: Context) -> V {
        builder()
    }
    
    func updateUIView(_ uiView: V, context: Context) {}
}
#endif