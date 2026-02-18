//
//  GithubRepository.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine

protocol GithubRepositoriesRepository {
    func fetchTrendingRepositories(searchText: String, daysBack: Int, page: Int) -> AnyPublisher<RepositoryPage, Never>
}
