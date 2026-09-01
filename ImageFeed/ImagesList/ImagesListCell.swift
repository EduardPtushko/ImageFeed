//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 31.07.2026.
//

import UIKit

final class ImagesListCell: UITableViewCell {

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var cellButton: UIButton!
    @IBOutlet private weak var cellImageView: UIImageView!
    @IBOutlet private weak var gradient: GradientView!

    static let reuseIdentifier = "ImagesListCell"

    func configure(image: UIImage?, date: String, isLiked: Bool) {
        cellImageView.image = image
        dateLabel.text = date

        let likeImage = UIImage(
            resource: isLiked ? .likeButtonOn : .likeButtonOff
        )
        cellButton.setImage(likeImage, for: .normal)

        gradient.setColors([.gradientStart, .gradientEnd])
    }
}
