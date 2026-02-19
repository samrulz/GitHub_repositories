//
//  MockGithubRepository.swift
//  GitHub RepositoriesTests
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine
@testable import GitHub_Repositories

/// Stub repository that replays a preconfigured RepositoryPage.
final class MockGithubRepository: GithubRepositoriesRepository {
    var stubbedPage: RepositoryPage
    var capturedSearchText: String?
    var capturedDaysBack: Int?
    var capturedPage: Int?

    init(stubbedPage: RepositoryPage) {
        self.stubbedPage = stubbedPage
    }

    func fetchTrendingRepositories(
        searchText: String,
        daysBack: Int,
        page: Int
    ) -> AnyPublisher<RepositoryPage, Never> {
        capturedSearchText = searchText
        capturedDaysBack = daysBack
        capturedPage = page
        return Just(stubbedPage).eraseToAnyPublisher()
    }
}
