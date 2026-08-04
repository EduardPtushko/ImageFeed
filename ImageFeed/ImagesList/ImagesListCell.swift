//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 31.07.2026.
//

import UIKit

class ImagesListCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var cellButton: UIButton!
    @IBOutlet var cellImageView: UIImageView!

    // MARK: - Static Properties

    static let reuseIdentifier = "ImagesListCell"
}
