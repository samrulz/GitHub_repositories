//
//  RepoListViewModel.swift
//  GitHub Repositories
//
//  Created by Sandip Musale on 18/02/26.
//

import Foundation
import Combine

class RepoListViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var repos: [Repository] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var isLoadingMore: Bool = false
    @Published private(set) var canLoadMore: Bool = false
    @Published private(set) var errorMessage: String? = nil
    @Published private(set) var isShowingCachedResults: Bool = false
    
    private let useCase: FetchTrendingRepositoriesUseCase
    private let debounceInterval: DispatchQueue.SchedulerTimeType.Stride
    private let scheduler: DispatchQueue
    private var cancellables = Set<AnyCancellable>()
    
    private var currentPage: Int = 1
    private var totalCount: Int = 0
    private var currentSearchText: String = ""
    
    init(
        useCase: FetchTrendingRepositoriesUseCase,
        debounceInterval: DispatchQueue.SchedulerTimeType.Stride = .milliseconds(400),
        scheduler: DispatchQueue = .main,
        autoLoad: Bool = true
    ) {
        self.useCase = useCase
        self.debounceInterval = debounceInterval
        self.scheduler = scheduler
        bindSearch()
        
        if autoLoad {
            performSearch(for: "")
        }
    }
    
    func refresh() async {
        await withCheckedContinuation { continuation in
            load(page: 1, replace: true) {
                continuation.resume()
            }
        }
    }
    
    func loadMoreIfNeeded(currentRepo: Repository?) {
        guard let currentRepo else {
            return
        }
        guard repos.count >= 5 else {
            return
        }
        let thresholdIndex = repos.index(repos.endIndex, offsetBy: -5)
        if let index = repos.firstIndex(where: { $0.id == currentRepo.id }), index >= thresholdIndex {
            loadNextPage()
        }
    }
    
    func loadNextPage() {
        guard canLoadMore, !isLoading, !isLoadingMore else {
            return
        }
        load(page: currentPage + 1, replace: false, completion: nil)
    }
    
    private func bindSearch() {
        $searchText
            .dropFirst()
            .debounce(for: debounceInterval, scheduler: scheduler)
            .removeDuplicates()
            .sink { [weak self] text in
                self?.performSearch(for: text)
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(for text: String) {
        currentSearchText = text
        totalCount = 0
        currentPage = 1
        load(page: 1, replace: true, completion: nil)
    }
    
    private func load(page: Int, replace: Bool, completion: (() -> Void)?) {
        if page == 1 {
            isLoading = true
        } else {
            isLoadingMore = true
        }
        
        let searchText = currentSearchText.isEmpty ? self.searchText : currentSearchText
        
        useCase.execute(searchText: searchText, page: page)
            .receive(on: scheduler)
            .sink { [weak self] result in
                guard let self else {
                    completion?()
                    return
                }
                
                if page == 1 {
                    self.isLoading = false
                } else {
                    self.isLoadingMore = false
                }
                
                if let error = result.error {
                    self.errorMessage = self.errorMessage(for: error, isFromCache: result.isFromCache)
                } else {
                    self.errorMessage = nil
                }
                
                self.isShowingCachedResults = result.isFromCache
                
                if replace {
                    if !result.repos.isEmpty || result.error == nil {
                        self.repos = result.repos
                        self.totalCount = max(result.totalCount, result.repos.count)
                        self.currentPage = page
                    }
                } else if !result.repos.isEmpty {
                    self.repos.append(contentsOf: result.repos)
                    self.totalCount = max(self.totalCount, result.totalCount)
                    self.currentPage = page
                }
                
                self.canLoadMore = self.repos.count < self.totalCount
                completion?()
            }
            .store(in: &cancellables)
    }
    
    private func errorMessage(for error: Error, isFromCache: Bool) -> String {
        if isFromCache {
            return "Showing cached results. \(error.localizedDescription)"
        }
        return error.localizedDescription
    }
}
