//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Eduard Ptushko on 25.08.2026.
//

import Foundation
import OSLog

// MARK: - Network Types

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - URLSession Extensions

extension URLSession {
    // MARK: - Raw Data Task

    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = {
            result in
            if case .failure(let error) = result {
                let urlString = request.url?.absoluteString ?? "unknown URL"
                Logger.logError(
                    category: .network,
                    "Сетевой запрос завершился неудачей для URL: \(urlString)",
                    error: error
                )
            }

            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request) { data, response, error in
            if let data, let response,
                let statusCode = (response as? HTTPURLResponse)?.statusCode
            {
                if 200..<300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(
                        .failure(NetworkError.httpStatusCode(statusCode))
                    )
                }
            } else if let error {
                fulfillCompletionOnTheMainThread(
                    .failure(NetworkError.urlRequestError(error))
                )
            } else {
                fulfillCompletionOnTheMainThread(
                    .failure(NetworkError.urlSessionError)
                )
            }
        }

        return task
    }

    // MARK: - Generic Object Task (JSON Decoding)

    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    Logger.network.debug("Полученный JSON-ответ: \(jsonString)")
                }
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    let rawDataString =
                        String(data: data, encoding: .utf8)
                        ?? "содержимое не является UTF8"

                    if let decodingError = error as? DecodingError {
                        switch decodingError {
                        case .typeMismatch(let type, let context):
                            Logger.logError(
                                category: .network,
                                "JSON Type Mismatch: Ожидался тип \(type) | Путь: \(context.codingPath)\nRaw Data: \(rawDataString)"
                            )
                        case .valueNotFound(let type, let context):
                            Logger.logError(
                                category: .network,
                                "JSON Value Not Found: Отсутствует значение для типа \(type) | Путь: \(context.codingPath)\nRaw Data: \(rawDataString)"
                            )
                        case .keyNotFound(let key, let context):
                            Logger.logError(
                                category: .network,
                                "❌ JSON Key Not Found: Бэкенд не прислал обязательный ключ '\(key.stringValue)' | Путь: \(context.codingPath)\nRaw Data: \(rawDataString)"
                            )
                        case .dataCorrupted(let context):
                            Logger.logError(
                                category: .network,
                                "JSON Data Corrupted: Структура файла повреждена | Контекст: \(context.debugDescription)\nRaw Data: \(rawDataString)"
                            )
                        @unknown default:
                            Logger.logError(
                                category: .network,
                                "Непредвиденная ошибка DecodingError",
                                error: error
                            )
                        }
                    } else {
                        Logger.logError(
                            category: .network,
                            "Общая ошибка при разборе данных",
                            error: error
                        )
                    }
                    completion(.failure(NetworkError.decodingError(error)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return task
    }
}
