//
//  APIService.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine

protocol APIClientProtocol {
    func fetch<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error>
}

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server."
        case .httpStatus(let code):
            return "Server returned status code \(code)."
        case .decodingFailed:
            return "Failed to decode server response."
        }
    }
}

final class GitHubAPIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func fetch<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        session.dataTaskPublisher(for: request)
            .tryMap { output in
                guard let response = output.response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                guard (200...299).contains(response.statusCode) else {
                    throw APIError.httpStatus(response.statusCode)
                }
                return output.data
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error in
                if error is DecodingError {
                    return APIError.decodingFailed
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}
