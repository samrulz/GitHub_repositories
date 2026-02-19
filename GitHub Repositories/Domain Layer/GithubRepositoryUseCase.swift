//
//  GithubRepositoryUseCase.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine

protocol FetchTrendingRepositoriesUseCase {
    func execute(searchText: String, page: Int) -> AnyPublisher<RepositoryPage, Never>
}

final class DefaultFetchTrendingRepositoriesUseCase: FetchTrendingRepositoriesUseCase {
    private let repository: GithubRepositoriesRepository
    private let daysBack: Int

    init(
        repository: GithubRepositoriesRepository,
        daysBack: Int = 7
    ) {
        self.repository = repository
        self.daysBack = daysBack
    }

    func execute(searchText: String, page: Int) -> AnyPublisher<RepositoryPage, Never> {
        repository.fetchTrendingRepositories(searchText: searchText, daysBack: daysBack, page: page)
    }
}
