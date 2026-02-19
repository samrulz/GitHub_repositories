//
//  GithubRepositoriesRepositoryImpl.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine
import CryptoKit

// Data-layer repository implementation backed by GitHub Search API + local cache.
final class GitHubRepositoriesRepository: GithubRepositoriesRepository {
    private let apiClient: GitHubAPIClient
    private let cacheStore: CacheStore
    private let queryBuilder: SearchQueryProtocol
    private let perPage: Int
    private let tokenProvider: () -> String?

    init(
        apiClient: GitHubAPIClient,
        cacheStore: CacheStore,
        queryBuilder: SearchQueryProtocol = SearchQueryBuilder(),
        perPage: Int = 20,
        tokenProvider: @escaping () -> String? = { ProcessInfo.processInfo.environment["GITHUB_TOKEN"] }
    ) {
        self.apiClient = apiClient
        self.cacheStore = cacheStore
        self.queryBuilder = queryBuilder
        self.perPage = perPage
        self.tokenProvider = tokenProvider
    }

    func fetchTrendingRepositories(searchText: String, daysBack: Int, page: Int) -> AnyPublisher<RepositoryPage, Never> {
        let query = queryBuilder.buildQuery(searchText: searchText, daysBack: daysBack)
        let request = makeRequest(query: query, page: page)
        let key = Self.cacheKey(query: query, page: page)

        return apiClient.fetch(request)
            .map { (response: RepoSearchResponseDTO) -> RepositoryPage in
                self.cacheStore.save(response, forKey: key)
                return RepositoryPage(
                    repos: response.items.map { $0.toDomain() },
                    totalCount: response.totalCount,
                    isFromCache: false,
                    error: nil
                )
            }
            .catch { error -> AnyPublisher<RepositoryPage, Never> in
                if let cached: RepoSearchResponseDTO = self.cacheStore.load(RepoSearchResponseDTO.self, forKey: key) {
                    return Just(
                        RepositoryPage(
                            repos: cached.items.map { $0.toDomain() },
                            totalCount: cached.totalCount,
                            isFromCache: true,
                            error: error
                        )
                    )
                    .eraseToAnyPublisher()
                }

                return Just(
                    RepositoryPage(
                        repos: [],
                        totalCount: 0,
                        isFromCache: false,
                        error: error
                    )
                )
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    static func cacheKey(query: String, page: Int) -> String {
        let raw = "\(query)|page:\(page)"
        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private func makeRequest(query: String, page: Int) -> URLRequest {
        var components = URLComponents(string: "https://api.github.com/search/repositories")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "sort", value: "stars"),
            URLQueryItem(name: "order", value: "desc"),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage))
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("TrendingReposApp", forHTTPHeaderField: "User-Agent")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        if let token = tokenProvider() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return request
    }
}
