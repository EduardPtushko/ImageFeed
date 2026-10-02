//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 21.09.2026.
//

import OSLog
import UIKit

final class ImagesListService {

    // MARK: - Constants

    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(
        "ImageListServiceDidChange"
    )

    // MARK: - Private Properties

    private(set) var photos: [Photo] = []
    private var fetchPhotosTask: URLSessionTask?
    private var changeLikeTask: URLSessionTask?
    private let session = URLSession.shared
    private let storage = OAuth2TokenStorage.shared
    private var lastLoadedPage: Int?

    private let formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        return formatter
    }()

    // MARK: - Init

    private init() {}

    // MARK: - Public Methods

    func fetchPhotosNextPage(
        completion: @escaping (Error?) -> Void
    ) {
        guard fetchPhotosTask == nil else {
            Logger.network.warning(
                "Запрос следующей страницы уже выполняется. Игнорируем дубликат."
            )
            return
        }

        guard let token = storage.token else {
            let tokenError = NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey: "Authorization token missing"
                ]
            )
            Logger.logError(
                category: .network,
                "AuthError - отсутствует токен авторизации для пользователя",
                error: tokenError
            )

            completion(tokenError)
            return
        }

        let nextPage = (lastLoadedPage ?? 0) + 1
        guard
            let request = makeImagesListRequest(
                token: token,
                nextPage: nextPage
            )
        else {
            let urlError = URLError(.badURL)
            Logger.logError(
                category: .network,
                "RequestCreationError - не удалось создать URLRequest для получения фотографий",
                error: urlError
            )
            completion(urlError)
            return
        }

        let task = session.objectTask(for: request) {
            [weak self] (request: Result<[PhotoResult], Error>) in

            guard let self else { return }

            DispatchQueue.main.async {
                switch request {
                case .success(let photoResult):

                    self.lastLoadedPage = nextPage
                    var newPhotos: [Photo] = []

                    for photo in photoResult {
                        let newPhoto = Photo(
                            id: photo.id,
                            size: CGSize(
                                width: photo.width,
                                height: photo.height
                            ),
                            createdAt: self.formatter.date(
                                from: photo.createdAt
                            ),
                            welcomeDescription: photo.description,
                            thumbImageURL: photo.urls.thumb,
                            largeImageURL: photo.urls.full,
                            isLiked: photo.likedByUser
                        )
                        newPhotos.append(newPhoto)
                    }
                    self.photos.append(contentsOf: newPhotos)
                    completion(nil)

                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )

                case .failure(let error):
                    Logger.logError(
                        category: .network,
                        "Не удалось получить массив фотографий",
                        error: error
                    )
                    completion(error)
                }
                self.fetchPhotosTask = nil
            }
        }

        self.fetchPhotosTask = task
        task.resume()

    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        changeLikeTask?.cancel()

        guard let token = storage.token else {
            let tokenError = NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [
                    NSLocalizedDescriptionKey: "Authorization token missing"
                ]
            )
            Logger.logError(
                category: .network,
                "AuthError - отсутствует токен авторизации для пользователя",
                error: tokenError
            )

            completion(.failure(tokenError))
            return
        }

        guard
            let request = makeChangeLikeRequest(
                photoId: photoId,
                token: token,
                httpMethod: isLike
                    ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
            )
        else {
            let urlError = URLError(.badURL)
            Logger.logError(
                category: .network,
                "RequestCreationError - не удалось создать URLRequest для изменения лайка",
                error: urlError
            )
            completion(.failure(urlError))
            return
        }

        let task = session.data(for: request) { [weak self] result in
            guard let self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    if let index = self.photos.firstIndex(where: {
                        $0.id == photoId
                    }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )

                        self.photos = self.photos.withReplaced(
                            itemAt: index,
                            newValue: newPhoto
                        )

                    }
                    completion(.success(()))
                case .failure(let error):
                    Logger.logError(
                        category: .network,
                        "Ошибка изменения статуса лайка для ID: \(photoId)",
                        error: error
                    )
                    completion(.failure(error))
                }
                self.changeLikeTask = nil
            }
        }
        self.changeLikeTask = task
        task.resume()

    }

    func clearImageListServiceData() {
        fetchPhotosTask?.cancel()
        fetchPhotosTask = nil

        changeLikeTask?.cancel()
        changeLikeTask = nil

        photos = []
        lastLoadedPage = nil

        Logger.network.info(
            "Данные ImagesListService успешно очищены при логауте."
        )
    }

    // MARK: - Private Methods

    private func makeImagesListRequest(token: String, nextPage: Int)
        -> URLRequest?
    {
        guard var urlComponents = URLComponents(string: Constants.URL.photos)
        else {
            assertionFailure("Failed to create URLComponents")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(nextPage)")
        ]

        guard let url = urlComponents.url else {
            Logger.logError(
                category: .network,
                "URLError - не удалось сформировать URL для строки: \(Constants.URL.photos)"
            )
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        return request
    }

    private func makeChangeLikeRequest(
        photoId: String,
        token: String,
        httpMethod: String
    ) -> URLRequest? {
        let urlString = "\(Constants.URL.photos)/\(photoId)/like"

        guard let url = URL(string: urlString) else {
            Logger.logError(
                category: .network,
                "[URLError - не удалось сформировать URL для строки: \(urlString)"
            )
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }

}
