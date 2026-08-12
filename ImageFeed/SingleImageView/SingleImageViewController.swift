//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 10.08.2026.
//

import UIKit

final class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }

    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = image
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true)
    }
}
