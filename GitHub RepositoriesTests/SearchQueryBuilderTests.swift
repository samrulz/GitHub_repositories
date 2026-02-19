//
//  SearchQueryBuilderTests.swift
//  GitHub RepositoriesTests
//
//  Created by Sandip Musale on 18/02/26.
//

import XCTest
@testable import GitHub_Repositories

final class SearchQueryBuilderTests: XCTestCase {
    
    private let fixedDate = ISO8601DateFormatter().date(from: "2025-06-15T00:00:00Z")!
    
    /// SUT configured with a fixed date of 2025-06-15 (UTC).
    private func makeSUT(daysBack: Int = 7) -> SearchQueryBuilder {
        SearchQueryBuilder(
            calendar: Calendar(identifier: .gregorian),
            dateProvider: { self.fixedDate }
        )
    }

    // Empty search text → only the "created:>" predicate.
    func test_buildQuery_emptySearchText_returnsOnlyDatePredicate() {
        let sut = makeSUT()
        let result = sut.buildQuery(searchText: "", daysBack: 7)
        // 2025-06-15 − 7 days = 2025-06-08
        XCTAssertEqual(result, "created:>2025-06-08")
    }

    // Whitespace-only search text is treated the same as empty.
    func test_buildQuery_whitespaceSearchText_returnsOnlyDatePredicate() {
        let sut = makeSUT()
        let result = sut.buildQuery(searchText: "   ", daysBack: 7)
        XCTAssertEqual(result, "created:>2025-06-08")
    }

    // Non-empty search text is appended after the date predicate.
    func test_buildQuery_nonEmptySearchText_appendsToDatePredicate() {
        let sut = makeSUT()
        let result = sut.buildQuery(searchText: "swift", daysBack: 7)
        XCTAssertEqual(result, "created:>2025-06-08 swift")
    }

    // Leading/trailing whitespace in search text is trimmed.
    func test_buildQuery_trimsSearchText() {
        let sut = makeSUT()
        let result = sut.buildQuery(searchText: "  swift  ", daysBack: 7)
        XCTAssertEqual(result, "created:>2025-06-08 swift")
    }

    // daysBack=0 → date equals the base date itself.
    func test_buildQuery_zeroDaysBack_usesFixedDateAsIs() {
        let sut = makeSUT()
        let result = sut.buildQuery(searchText: "", daysBack: 0)
        XCTAssertEqual(result, "created:>2025-06-15")
    }

    // daysBack=30.
    func test_buildQuery_thirtyDaysBack() {
        let sut = makeSUT()
        let result = sut.buildQuery(searchText: "", daysBack: 30)
        XCTAssertEqual(result, "created:>2025-05-16")
    }

    // Query format always starts with "created:>".
    func test_buildQuery_alwaysStartsWithCreatedPredicate() {
        let sut = makeSUT()
        XCTAssertTrue(sut.buildQuery(searchText: "kotlin", daysBack: 14).hasPrefix("created:>"))
    }
}
