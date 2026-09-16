//
//  CellPreviewContainer.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 16.09.2026.
//


#if DEBUG
import SwiftUI

struct CellPreviewContainer<Cell: UITableViewCell>: UIViewRepresentable {
    private let style: UITableViewCell.CellStyle
    private let configure: (Cell) -> Void

    init(
        style: UITableViewCell.CellStyle = .default,
        configure: @escaping (Cell) -> Void
    ) {
        self.style = style
        self.configure = configure
    }

    func makeUIView(context: Context) -> UIView {

        let cell = Cell(style: style, reuseIdentifier: "PreviewCell")

        configure(cell)
        return cell
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
#endif
