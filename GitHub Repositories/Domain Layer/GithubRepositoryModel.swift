//
//  RepositoryModel.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation

struct RepositoryPage {
    let repos: [Repository]
    let totalCount: Int
    let isFromCache: Bool
    let error: Error?
}

struct Repository: Identifiable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let language: String?
    let htmlUrl: URL
    let owner: Owner
}

struct Owner: Equatable {
    let login: String
    let avatarUrl: URL
}
