//
//  RepoListViewModelTests.swift
//  GitHub RepositoriesTests
//
//  Created by Sandip Musale on 19/02/26.
//

import XCTest
import Combine
@testable import GitHub_Repositories

@MainActor
final class RepoListViewModelTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()
    
    // Helper: creates a ViewModel that does NOT auto-load and uses a synchronous scheduler.
    private func makeSUT(
        page: RepositoryPage,
        autoLoad: Bool = false
    ) -> (RepoListViewModel, MockUseCase) {
        let mock = MockUseCase(stubbedPage: page)
        let vm = RepoListViewModel(
            useCase: mock,
            debounceInterval: .milliseconds(0),
            scheduler: .main,
            autoLoad: autoLoad
        )
        return (vm, mock)
    }
    
    // autoLoad=true triggers an initial fetch on creation.
    func test_autoLoad_fetchesOnInit() async {
        let mock = MockUseCase(stubbedPage: makePage(repos: [makeRepository()], totalCount: 1))
        _ = RepoListViewModel(
            useCase: mock,
            debounceInterval: .milliseconds(0),
            scheduler: .main,
            autoLoad: true
        )
        // Yield to let Combine publish synchronously on main.
        await Task.yield()
        XCTAssertGreaterThanOrEqual(mock.callCount, 1)
    }
    
    // Initial state: no repos, not loading, no error.
    func test_initialState_whenAutoLoadFalse() async {
        let (vm, _) = makeSUT(page: makePage())
        XCTAssertTrue(vm.repos.isEmpty)
        XCTAssertFalse(vm.isLoading)
        XCTAssertNil(vm.errorMessage)
    }
    
    // After a successful load repos are populated.
    func test_load_populatesRepos() async {
        let repos = [makeRepository(id: 1), makeRepository(id: 2)]
        let (vm, _) = makeSUT(page: makePage(repos: repos, totalCount: 2))
        await vm.refresh()
        XCTAssertEqual(vm.repos.count, 2)
    }
    
    // isLoading is false after refresh completes.
    func test_afterRefresh_isLoadingIsFalse() async {
        let (vm, _) = makeSUT(page: makePage(repos: [makeRepository()], totalCount: 1))
        await vm.refresh()
        XCTAssertFalse(vm.isLoading)
    }
    
    // errorMessage is nil on a successful response.
    func test_successfulLoad_noErrorMessage() async {
        let (vm, _) = makeSUT(page: makePage(repos: [makeRepository()], totalCount: 1))
        await vm.refresh()
        XCTAssertNil(vm.errorMessage)
    }
    
    // When the page has an error (no cache), errorMessage is set.
    func test_errorLoad_setsErrorMessage() async {
        let page = makePage(repos: [], totalCount: 0, isFromCache: false, error: APIError.invalidResponse)
        let (vm, _) = makeSUT(page: page)
        await vm.refresh()
        XCTAssertNotNil(vm.errorMessage)
    }
    
    // When response is from cache and has an error, message says "cached".
    func test_cachedErrorLoad_errorMessageMentionsCached() async {
        let page = makePage(
            repos: [makeRepository()],
            totalCount: 1,
            isFromCache: true,
            error: APIError.httpStatus(503)
        )
        let (vm, _) = makeSUT(page: page)
        await vm.refresh()
        XCTAssertTrue(vm.errorMessage?.lowercased().contains("cache") == true)
    }
    
    // isShowingCachedResults reflects the RepositoryPage flag.
    func test_cachedPage_isShowingCachedResultsIsTrue() async {
        let page = makePage(repos: [makeRepository()], totalCount: 1, isFromCache: true, error: APIError.invalidResponse)
        let (vm, _) = makeSUT(page: page)
        await vm.refresh()
        XCTAssertTrue(vm.isShowingCachedResults)
    }
    
    // canLoadMore is true when repos.count < totalCount.
    func test_canLoadMore_whenMoreResultsAvailable() async {
        let repos = (1...5).map { makeRepository(id: $0) }
        let page = makePage(repos: repos, totalCount: 100)
        let (vm, _) = makeSUT(page: page)
        await vm.refresh()
        XCTAssertTrue(vm.canLoadMore)
    }
    
    // canLoadMore is false when all results are loaded.
    func test_canLoadMore_falseWhenAllLoaded() async {
        let repos = [makeRepository()]
        let page = makePage(repos: repos, totalCount: 1)
        let (vm, _) = makeSUT(page: page)
        await vm.refresh()
        XCTAssertFalse(vm.canLoadMore)
    }
    
    // loadMoreIfNeeded with nil repo does nothing.
    func test_loadMoreIfNeeded_nilRepo_doesNotTriggerLoad() async {
        let (vm, mock) = makeSUT(page: makePage())
        vm.loadMoreIfNeeded(currentRepo: nil)
        await Task.yield()
        XCTAssertEqual(mock.callCount, 0)
    }
    
    // loadMoreIfNeeded when not near end does nothing.
    func test_loadMoreIfNeeded_notNearEnd_doesNotLoad() async {
        // 10 repos loaded, canLoadMore = true (totalCount=100).
        let repos = (1...10).map { makeRepository(id: $0) }
        let page = makePage(repos: repos, totalCount: 100)
        let (vm, mock) = makeSUT(page: page)
        await vm.refresh()
        let callsAfterRefresh = mock.callCount
        
        // Ask about the very first repo — far from the end.
        vm.loadMoreIfNeeded(currentRepo: repos[0])
        await Task.yield()
        
        // Call count should not have increased.
        XCTAssertEqual(mock.callCount, callsAfterRefresh)
    }
    
    // refresh replaces existing repos.
    func test_refresh_replacesExistingRepos() async {
        let first = [makeRepository(id: 1)]
        let second = [makeRepository(id: 99)]
        
        let mock = MockUseCase(stubbedPage: makePage(repos: first, totalCount: 1))
        let vm = RepoListViewModel(
            useCase: mock,
            debounceInterval: .milliseconds(0),
            scheduler: .main,
            autoLoad: false
        )
        await vm.refresh()
        XCTAssertEqual(vm.repos.first?.id, 1)
        
        // Swap stub to return different repos.
        mock.stubbedPage = makePage(repos: second, totalCount: 1)
        await vm.refresh()
        XCTAssertEqual(vm.repos.count, 1)
        XCTAssertEqual(vm.repos.first?.id, 99)
    }
    
    // Empty result from network with nil error clears repos.
    func test_emptySuccessfulPage_clearsRepos() async {
        let initial = makePage(repos: [makeRepository()], totalCount: 1)
        let mock = MockUseCase(stubbedPage: initial)
        let vm = RepoListViewModel(
            useCase: mock,
            debounceInterval: .milliseconds(0),
            scheduler: .main,
            autoLoad: false
        )
        await vm.refresh()
        XCTAssertEqual(vm.repos.count, 1)
        
        mock.stubbedPage = makePage(repos: [], totalCount: 0)
        await vm.refresh()
        XCTAssertTrue(vm.repos.isEmpty)
    }
}
