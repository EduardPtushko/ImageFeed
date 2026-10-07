//
//  ViewController.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 24.07.2026.
//

import Kingfisher
import OSLog
import UIKit

final class ImagesListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(resource: .ypBlack)
        tableView.separatorStyle = .none
        return tableView
    }()

    // MARK: - Private Properties

    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    private var photos: [Photo] = []

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    private func setupUI() {
        view.addSubview(tableView)
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            ImagesListCell.self,
            forCellReuseIdentifier: ImagesListCell.reuseIdentifier
        )
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        setupTable()
        tableView.contentInset = UIEdgeInsets(
            top: 12,
            left: 0,
            bottom: 12,
            right: 0
        )

        fetchPhotos()

        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main,
            using: { [weak self] _ in
                guard let self else { return }
                updateTableViewAnimated()
            }
        )
    }

    deinit {
        if let imagesListServiceObserver {
            NotificationCenter.default.removeObserver(imagesListServiceObserver)
        }
    }
}

// MARK: - Private Methods

extension ImagesListViewController {
    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos

        if oldCount != newCount {
            Logger.network.info(
                "Служба обновила массив фото. Было: \(oldCount), стало: \(newCount)"
            )

            tableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }

                tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }

    private func fetchPhotos() {
        Logger.network.info("Запрос следующей страницы с Unsplash")

        imagesListService.fetchPhotosNextPage { error in
            if let error {
                Logger.logError(
                    category: .network,
                    "Не удалось загрузить следующую страницу фотографий",
                    error: error
                )
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        )

        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self

        let photo = photos[indexPath.row]
        let dateString =
            photo.createdAt != nil
            ? dateFormatter.string(from: photo.createdAt!) : ""

        imageListCell.configure(
            image: photo.thumbImageURL,
            date: dateString,
            isLiked: photo.isLiked
        )

        return imageListCell
    }
}

// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        let viewController = SingleImageViewController()
        let photo = photos[indexPath.row]

        viewController.imageUrl = photo.largeImageURL
        viewController.modalPresentationStyle = .fullScreen

        present(viewController, animated: true)
    }

    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageSize = photo.size

        guard imageSize.width > 0 else { return 0 }

        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth =
            tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = imageSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight =
            imageSize.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }

    func tableView(
        _ tableView: UITableView,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        if indexPath.row + 1 == photos.count {
            fetchPhotos()
        }
    }
}
// MARK: - ImagesListCellDelegate

extension ImagesListViewController: ImagesListCellDelegate {
    func imagesListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]

        UIBlockingProgressHUD.show()

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked)
        { [weak self] result in

            guard let self else { return }

            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                Logger.network.info(
                    "Состояние лайка успешно изменнено для фото с ID: \(photo.id)"
                )
            case .failure(let error):
                Logger.logError(
                    category: .network,
                    "Не удалось изменить состояние лайка для фото с ID: \(photo.id)",
                    error: error
                )
            }
        }

    }
}

#Preview {
    ImagesListViewController()
}
