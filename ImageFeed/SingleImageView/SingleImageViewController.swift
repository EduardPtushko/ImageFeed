//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 10.08.2026.
//

import Kingfisher
import OSLog
import SwiftUI
import UIKit

final class SingleImageViewController: UIViewController {

    // MARK: - UI Elements

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = true
        return imageView
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(resource: .navBackButtonWhite)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(didTapBackButton),
            for: .touchUpInside
        )
        return button
    }()

    private lazy var shareButton: UIButton = {
        let button = UIButton()
        let image = UIImage(resource: .shareButton)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(didTapShareButton),
            for: .touchUpInside
        )
        return button
    }()

    // MARK: - Properties

    var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }

            imageView.image = image
            scrollView.setZoomScale(1.0, animated: false)
            imageView.frame.size = image.size
            scrollView.contentSize = image.size
            rescaleAndCenterImageInScrollView(image: image)
        }
    }

    var imageUrl: String?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()

        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25

        loadNetworkImage()
    }

    private func loadNetworkImage() {
        guard let imageUrl, let url = URL(string: imageUrl) else {
            return
        }
        UIBlockingProgressHUD.show()

        imageView.kf.setImage(with: url) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }

            switch result {
            case .success(let value):
                self.image = value.image
            case .failure(let error):
                Logger.logError(
                    category: .images,
                    "Не удалось загрузить картинку с Unsplash",
                    error: error
                )
                if !error.isTaskCancelled {
                    self.showError()
                }
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),

            backButton.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 8
            ),
            backButton.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                constant: 8
            ),
            backButton.widthAnchor.constraint(equalToConstant: 48),
            backButton.heightAnchor.constraint(equalToConstant: 48),

            shareButton.bottomAnchor.constraint(
                equalTo: view.bottomAnchor,
                constant: -17
            ),
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50),

        ])
    }

    // MARK: - Actions

    @objc private func didTapBackButton() {
        imageView.kf.cancelDownloadTask()

        dismiss(animated: true)
    }

    @objc private func didTapShareButton() {
        guard let image else { return }
        let itemsToShare: [Any] = [image]
        let activityController = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        present(activityController, animated: true, completion: nil)
    }

    // MARK: - Private Methods

    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
}

// MARK: - UIScrollViewDelegate

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
}

extension SingleImageViewController {
    private func showError() {
        let alert = UIAlertController(
            title: "",
            message: "Что-то пошло не так. Попробовать ещё раз?",
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Alert"
        let logoutAction = UIAlertAction(title: "Повторить", style: .default) {
            [weak self] _ in
            guard let self else { return }
            self.loadNetworkImage()
        }
        let cancelAction = UIAlertAction(title: "Не надо", style: .default)

        alert.addAction(logoutAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}

#Preview {
    ViewControllerPreview {
        let viewController = SingleImageViewController()
        _ = viewController.view
        //        viewController.image = UIImage(resource: ._3)
        viewController.imageUrl =
            "https://images.unsplash.com/photo-1779896412192-cca060dfafde?crop=entropy&cs=srgb&fm=jpg&ixid=M3wxMDMzNDkyfDF8MXxhbGx8MXx8fHx8fHx8MTc5MDE4MDE3OHw&ixlib=rb-4.1.0&q=85"
        return viewController
    }
    .ignoresSafeArea()
}
