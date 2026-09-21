//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 31.07.2026.
//

import SwiftUI
import UIKit

final class ImagesListCell: UITableViewCell {

    static let reuseIdentifier = "ImagesListCell"

    // MARK: - UI Elements

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(resource: .ypWhite)
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private lazy var cellButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    private lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 16
        return imageView
    }()

    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.startColor = .clear
        view.endColor = .black.withAlphaComponent(0.7)
        view.bottomCornerRadius = 12
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = UIColor(resource: .ypBlack)
        contentView.backgroundColor = UIColor(resource: .ypBlack)
        selectionStyle = .none

        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup Methods

    private func setupViews() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(cellButton)
        contentView.addSubview(dateLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cellImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: 16
            ),
            cellImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -16
            ),
            cellImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: 4
            ),
            cellImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: 4
            ),

            cellButton.widthAnchor.constraint(equalToConstant: 44),
            cellButton.heightAnchor.constraint(equalToConstant: 44),
            cellButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            cellButton.trailingAnchor.constraint(
                equalTo: cellImageView.trailingAnchor
            ),

            gradientView.heightAnchor.constraint(equalToConstant: 30),
            gradientView.leadingAnchor.constraint(
                equalTo: cellImageView.leadingAnchor
            ),
            gradientView.trailingAnchor.constraint(
                equalTo: cellImageView.trailingAnchor
            ),
            gradientView.bottomAnchor.constraint(
                equalTo: cellImageView.bottomAnchor
            ),

            dateLabel.leadingAnchor.constraint(
                equalTo: gradientView.leadingAnchor,
                constant: 8
            ),
            dateLabel.bottomAnchor.constraint(
                equalTo: gradientView.bottomAnchor,
                constant: -8
            ),
        ])
    }

    func configure(image: UIImage?, date: String, isLiked: Bool) {
        cellImageView.image = image
        dateLabel.text = date

        let likeImage = UIImage(
            resource: isLiked ? .likeButtonOn : .likeButtonOff
        )
        cellButton.setImage(likeImage, for: .normal)

        gradientView.setColors([.gradientStart, .gradientEnd])
    }
}

#Preview {

    List {
        CellPreviewContainer<ImagesListCell> { cell in

            cell.configure(
                image: UIImage(named: "0"),
                date: "16 сентября 2026",
                isLiked: false
            )
        }
        .frame(height: 200)
        .listRowBackground(Color.ypBlack)

        CellPreviewContainer<ImagesListCell> { cell in

            cell.configure(
                image: UIImage(named: "2"),
                date: "16 сентября 2026",
                isLiked: true
            )
        }
        .frame(height: 200)
        .listRowBackground(Color.ypBlack)

    }
    .listStyle(.plain)
    .scrollContentBackground(.hidden)
    .background(Color.ypBlack)
}
