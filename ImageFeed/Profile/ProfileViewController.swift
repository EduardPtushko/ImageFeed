//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 06.08.2026.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private var avatarImageView: UIImageView!
     @IBOutlet private var nameLabel: UILabel!
     @IBOutlet private var loginNameLabel: UILabel!
     @IBOutlet private var descriptionLabel: UILabel!

     @IBOutlet private var logoutButton: UIButton!

     @IBAction private func didTapLogoutButton() {
     }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
