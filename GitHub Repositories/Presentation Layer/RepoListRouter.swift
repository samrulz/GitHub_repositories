//
//  RepoListRouter.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine
import SwiftUI

/// Router for list -> detail navigation in the repos flow.
/// Owns route state and exposes simple routing commands.
final class RepoListRouter: ObservableObject {
    @Published private(set) var selectedRepository: Repository?

    var isDetailActive: Bool {
        selectedRepository != nil
    }

    func showDetails(for repository: Repository) {
        selectedRepository = repository
    }

    func dismissDetails() {
        selectedRepository = nil
    }

    var destinationView: AnyView {
        if let selectedRepository {
            return AnyView(RepoDetailView(viewModel: RepoDetailViewModel(repo: selectedRepository)))
        }
        return AnyView(EmptyView())
    }
}

