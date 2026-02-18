//
//  RepoDetailViewModel.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine

final class RepoDetailViewModel: ObservableObject {
    let repo: Repository

    init(repo: Repository) {
        self.repo = repo
    }

    var title: String {
        repo.name
    }

    var subtitle: String {
        repo.fullName
    }

    var descriptionText: String {
        repo.description ?? "No description provided."
    }

    var starsText: String {
        "\(repo.stargazersCount) stars"
    }

    var forksText: String {
        "\(repo.forksCount) forks"
    }

    var languageText: String {
        repo.language ?? "Unknown"
    }
}
