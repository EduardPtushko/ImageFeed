//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 31.07.2026.
//

import Kingfisher
import SwiftUI
import UIKit

// MARK: - ImagesListCellDelegate

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {

    // MARK: - Public Properties

    static let reuseIdentifier = "ImagesListCell"
    weak var delegate: ImagesListCellDelegate?

    // MARK: - UI Elements

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(resource: .ypWhite)
        label.font = .systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(likeButtonTapped),
            for: .touchUpInside
        )
        return button
    }()

    lazy var cellImageView: UIImageView = {
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
        view.bottomCornerRadius = 16
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

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Setup Methods

    private func setupViews() {
        contentView.addSubview(cellImageView)
        contentView.addSubview(gradientView)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
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
                constant: -4
            ),

            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44),
            likeButton.topAnchor.constraint(equalTo: cellImageView.topAnchor),
            likeButton.trailingAnchor.constraint(
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

    // MARK: - Override

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
        cellImageView.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }

    // MARK: - Public Methods

    func configure(image: String, date: String, isLiked: Bool) {
        guard let cellImageURL = URL(string: image) else { return }

        let cellImagePlaceholder = UIImage(resource: .stub)

        cellImageView.kf.indicatorType = .activity
        cellImageView.kf.setImage(
            with: cellImageURL,
            placeholder: cellImagePlaceholder,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
            ]
        )

        dateLabel.text = date
        setIsLiked(isLiked)
        gradientView.setColors([.gradientStart, .gradientEnd])
    }

    func setIsLiked(_ isLiked: Bool) {
        let likeImage = UIImage(
            resource: isLiked ? .likeButtonOn : .likeButtonOff
        )
        likeButton.setImage(likeImage, for: .normal)
    }

    // MARK: - Actions

    @objc private func likeButtonTapped() {
        delegate?.imagesListCellDidTapLike(self)
    }

}

#Preview {

    List {
        CellPreviewContainer<ImagesListCell> { cell in

            cell.configure(
                image:
                    "https://images.unsplash.com/photo-1779896412192-cca060dfafde?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3wxMDMzNDkyfDF8MXxhbGx8MXx8fHx8fHx8MTc5MDE4MDE3OHw&ixlib=rb-4.1.0&q=80&w=200",
                date: "16 сентября 2026",
                isLiked: false
            )
        }
        .frame(height: 200)
        .listRowBackground(Color.ypBlack)

        CellPreviewContainer<ImagesListCell> { cell in

            cell.configure(
                image: "https://picsum.photos/200/300",
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
