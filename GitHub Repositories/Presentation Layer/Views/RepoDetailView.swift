//
//  RepoDetailView.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import SwiftUI

struct RepoDetailView: View {
    @StateObject private var viewModel: RepoDetailViewModel

    init(viewModel: RepoDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(viewModel.descriptionText)
                    .font(.body)

                VStack(alignment: .leading, spacing: 8) {
                    Label(viewModel.starsText, systemImage: "star.fill")
                        .foregroundColor(.yellow)
                    Label(viewModel.forksText, systemImage: "tuningfork")
                        .foregroundColor(.mint)
                    Label(viewModel.languageText, systemImage: "chevron.left.slash.chevron.right")
                        .foregroundColor(.blue)
                }
                .font(.subheadline)

                Link("Open on GitHub", destination: viewModel.repo.htmlUrl)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
