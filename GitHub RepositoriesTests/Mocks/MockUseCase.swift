//
//  MockUseCase.swift
//  GitHub RepositoriesTests
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine
@testable import GitHub_Repositories

/// Stub use-case that replays a preconfigured RepositoryPage.
final class MockUseCase: FetchTrendingRepositoriesUseCase {
    var stubbedPage: RepositoryPage
    var callCount: Int = 0
    var capturedSearchText: String?
    var capturedPage: Int?
    
    init(stubbedPage: RepositoryPage) {
        self.stubbedPage = stubbedPage
    }
    
    func execute(searchText: String, page: Int) -> AnyPublisher<RepositoryPage, Never> {
        callCount += 1
        capturedSearchText = searchText
        capturedPage = page
        return Just(stubbedPage).eraseToAnyPublisher()
    }
}

// MARK: - Factory helpers
func makeOwnerDTO(
    login: String = "octocat",
    avatarUrl: URL = URL(string: "https://avatars.githubusercontent.com/u/1?v=4")!
) -> OwnerDTO {
    OwnerDTO(login: login, avatarUrl: avatarUrl)
}

func makeRepoDTO(
    id: Int = 1,
    name: String = "test-repo",
    fullName: String = "octocat/test-repo",
    description: String? = "A test repository",
    stargazersCount: Int = 42,
    forksCount: Int = 7,
    language: String? = "Swift",
    htmlUrl: URL = URL(string: "https://github.com/octocat/test-repo")!,
    owner: OwnerDTO? = nil
) -> RepositoryDTO {
    RepositoryDTO(
        id: id,
        name: name,
        fullName: fullName,
        description: description,
        stargazersCount: stargazersCount,
        forksCount: forksCount,
        language: language,
        htmlUrl: htmlUrl,
        owner: owner ?? makeOwnerDTO()
    )
}

func makeRepository(
    id: Int = 1,
    name: String = "test-repo",
    fullName: String = "octocat/test-repo",
    description: String? = "A test repository",
    stargazersCount: Int = 42,
    forksCount: Int = 7,
    language: String? = "Swift"
) -> Repository {
    Repository(
        id: id,
        name: name,
        fullName: fullName,
        description: description,
        stargazersCount: stargazersCount,
        forksCount: forksCount,
        language: language,
        htmlUrl: URL(string: "https://github.com/octocat/test-repo")!,
        owner: Owner(
            login: "octocat",
            avatarUrl: URL(string: "https://avatars.githubusercontent.com/u/1?v=4")!
        )
    )
}

func makePage(
    repos: [Repository] = [],
    totalCount: Int = 0,
    isFromCache: Bool = false,
    error: Error? = nil
) -> RepositoryPage {
    RepositoryPage(repos: repos, totalCount: totalCount, isFromCache: isFromCache, error: error)
}
