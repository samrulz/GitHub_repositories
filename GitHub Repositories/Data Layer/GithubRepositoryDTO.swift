//
//  GithubRepositoryDTO.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation

struct RepoSearchResponseDTO: Codable, Equatable {
    let totalCount: Int
    let items: [RepositoryDTO]
}

struct RepositoryDTO: Codable, Equatable {
    let id: Int
    let name: String
    let fullName: String
    let description: String?
    let stargazersCount: Int
    let forksCount: Int
    let language: String?
    let htmlUrl: URL
    let owner: OwnerDTO

    func toDomain() -> Repository {
        Repository(
            id: id,
            name: name,
            fullName: fullName,
            description: description,
            stargazersCount: stargazersCount,
            forksCount: forksCount,
            language: language,
            htmlUrl: htmlUrl,
            owner: owner.toDomain()
        )
    }
}

struct OwnerDTO: Codable, Equatable {
    let login: String
    let avatarUrl: URL

    func toDomain() -> Owner {
        Owner(login: login, avatarUrl: avatarUrl)
    }
}
