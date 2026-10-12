//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 12.10.2026.
//

import Foundation
import OSLog

protocol ImagesListViewPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func photosCount() -> Int
    func didTapOnTableRow(at indexRow: Int)
    func willDisplayCell(indexRow: Int)
    func calculateHeightForRow(at index: Int, tableViewWidth: CGFloat)
        -> CGFloat
    func configureCell(_ cell: ImagesListCellProtocol, at index: Int)
    func didTapCellLike(index: Int)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {

    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []
    
    weak var view: (any ImagesListViewControllerProtocol)?

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    func viewDidLoad() {
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

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos

        if oldCount != newCount {
            Logger.network.info(
                "Служба обновила массив фото. Было: \(oldCount), стало: \(newCount)"
            )

            let newIndices = IndexSet(oldCount..<newCount)
            view?.insertRows(at: newIndices)
        }
    }

    func configureCell(_ cell: any ImagesListCellProtocol, at index: Int) {
        let photo = photos[index]
        let dateString =
            photo.createdAt.map { dateFormatter.string(from: $0) } ?? ""

        cell.configure(
            image: photo.thumbImageURL,
            date: dateString,
            isLiked: photo.isLiked
        )
    }

    func calculateHeightForRow(at index: Int, tableViewWidth: CGFloat)
        -> CGFloat
    {
        guard photos.indices.contains(index) else { return 0 }
        let photo = photos[index]
        let imageSize = photo.size

        guard imageSize.width > 0 else { return 0 }

        let horizontalPadding: CGFloat = 16 + 16
        let verticalPadding: CGFloat = 4 + 4

        let imageViewWidth =
            tableViewWidth - horizontalPadding
        let imageWidth = imageSize.width
        let scale = imageViewWidth / imageWidth
        let cellHeight =
            imageSize.height * scale + verticalPadding
        return cellHeight
    }
    
    func willDisplayCell(indexRow: Int) {
        if indexRow + 1 == photos.count {
            fetchPhotos()
        }
    }

    func didTapOnTableRow(at indexRow: Int) {
        let photo = photos[indexRow]
        view?.showSingleViewImage(imageURLString: photo.largeImageURL)
    }

    func photosCount() -> Int {
        photos.count
    }

    func didTapCellLike(index: Int) {
        let photo = photos[index]

        view?.showProgressHUD()

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked)
        { [weak self] result in
            guard let self else { return }

            view?.dismissProgressHUD()
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                self.view?.updateRow(at: index)
                Logger.network.info(
                    "Состояние лайка успешно изменено для фото с ID: \(photo.id)"
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
