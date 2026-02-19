//
//  InMemoryCacheStoreTests.swift
//  GitHub RepositoriesTests
//
//  Created by Sandip Musale on 18/02/26.
//

import XCTest
@testable import GitHub_Repositories

final class InMemoryCacheStoreTests: XCTestCase {
    
    private var sut: InMemoryCacheStore!
    
    override func setUp() {
        super.setUp()
        sut = InMemoryCacheStore()
    }
    
    // Loading a key that was never stored returns nil.
    func test_load_missingKey_returnsNil() {
        XCTAssertNil(sut.load(String.self, forKey: "missing"))
    }
    
    // Saving and then loading a simple value round-trips correctly.
    func test_saveAndLoad_roundTrips() {
        sut.save("hello", forKey: "greet")
        XCTAssertEqual(sut.load(String.self, forKey: "greet"), "hello")
    }
    
    // Saving a struct round-trips through JSON encoding correctly.
    func test_saveAndLoad_struct_roundTrips() {
        let dto = RepoSearchResponseDTO(totalCount: 2, items: [makeRepoDTO(), makeRepoDTO(id: 2)])
        sut.save(dto, forKey: "page1")
        let loaded = sut.load(RepoSearchResponseDTO.self, forKey: "page1")
        XCTAssertEqual(loaded, dto)
    }
    
    // Overwriting the same key returns the latest value.
    func test_overwrite_returnsNewValue() {
        sut.save("first", forKey: "k")
        sut.save("second", forKey: "k")
        XCTAssertEqual(sut.load(String.self, forKey: "k"), "second")
    }
    
    // Two different keys are independent.
    func test_differentKeys_areIndependent() {
        sut.save("one", forKey: "k1")
        sut.save("two", forKey: "k2")
        XCTAssertEqual(sut.load(String.self, forKey: "k1"), "one")
        XCTAssertEqual(sut.load(String.self, forKey: "k2"), "two")
    }
    
    // Loading a value with a wrong type returns nil (decode failure).
    func test_load_wrongType_returnsNil() {
        sut.save(42, forKey: "num")
        XCTAssertNil(sut.load(String.self, forKey: "num"))
    }
}
