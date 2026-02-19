//
//  GitHub_RepositoriesApp.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import SwiftUI

@main
struct GitHub_RepositoriesApp: App {
    private let useCase: FetchTrendingRepositoriesUseCase

    init() {
        let apiClient = GitHubAPIClient()
        let cacheStore = DiskCacheStore()
        let repository = GitHubRepositoriesRepository(apiClient: apiClient, cacheStore: cacheStore)
        self.useCase = DefaultFetchTrendingRepositoriesUseCase(repository: repository)
    }

    var body: some Scene {
        WindowGroup {
            RepoListView(viewModel: RepoListViewModel(useCase: useCase))
        }
    }
}
