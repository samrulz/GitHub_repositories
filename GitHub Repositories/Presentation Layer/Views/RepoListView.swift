//
//  RepoListView.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import SwiftUI

struct RepoListView: View {
    @StateObject private var viewModel: RepoListViewModel
    @StateObject private var router: RepoListRouter

    init(viewModel: RepoListViewModel, router: RepoListRouter = RepoListRouter()) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _router = StateObject(wrappedValue: router)
    }

    private var detailBinding: Binding<Bool> {
        Binding(
            get: { router.isDetailActive },
            set: { isActive in
                if !isActive {
                    router.dismissDetails()
                }
            }
        )
    }

    var body: some View {
        NavigationView {
            ZStack {
                List {
                    if viewModel.isShowingCachedResults {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.orange)
                            Text("Showing cached results")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    ForEach(viewModel.repos) { repo in
                        Button {
                            router.showDetails(for: repo)
                        } label: {
                            RepoRowView(repo: repo)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentRepo: repo)
                        }
                    }

                    if viewModel.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if viewModel.canLoadMore {
                        Button("Load more") {
                            viewModel.loadNextPage()
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listStyle(.plain)
                .navigationTitle("Trending Repos")
                .searchable(text: $viewModel.searchText, prompt: "Search repositories")
                .overlay {
                    if viewModel.isLoading && viewModel.repos.isEmpty {
                        ProgressView("Loading...")
                    }
                }
                .refreshable {
                    await viewModel.refresh()
                }
                .safeAreaInset(edge: .top) {
                    if let errorMessage = viewModel.errorMessage {
                        ErrorBanner(text: errorMessage)
                    }
                }

                NavigationLink(
                    destination: router.destinationView,
                    isActive: detailBinding
                ) {
                    EmptyView()
                }
                .hidden()
            }
        }
    }
}

struct RepoRowView: View {
    let repo: Repository

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: repo.owner.avatarUrl) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 44, height: 44)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 44, height: 44)
                case .failure:
                    Image(systemName: "person.crop.square")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.secondary)
                @unknown default:
                    EmptyView()
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(repo.name)
                    .font(.headline)
                Text(repo.fullName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("\(repo.stargazersCount)")
                            .font(.caption)
                    }

                    if let language = repo.language {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left.slash.chevron.right")
                                .font(.caption)
                                .foregroundColor(.blue)
                            Text(language)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

