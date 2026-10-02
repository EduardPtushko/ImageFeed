//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 15.09.2026.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        tabBar.tintColor = .white
        tabBar.barTintColor = UIColor(resource: .ypBlack)

        let imagesListViewController = ImagesListViewController()
        imagesListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabEditorialActive),
            selectedImage: nil
        )

        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .tabProfileActive),
            selectedImage: nil
        )

        self.viewControllers = [
            imagesListViewController,
            profileViewController,
        ]
    }
}
