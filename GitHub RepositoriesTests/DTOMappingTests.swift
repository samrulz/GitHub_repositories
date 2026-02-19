//
//  DTOMappingTests.swift
//  GitHub RepositoriesTests
//
//  Created by Sandip Musale on 18/02/26.
//

import XCTest
@testable import GitHub_Repositories

final class DTOMappingTests: XCTestCase {
    
    // OwnerDTO.toDomain() maps all fields.
    func test_ownerDTO_toDomain_mapsAllFields() {
        let avatarURL = URL(string: "https://example.com/avatar.png")!
        let dto = OwnerDTO(login: "alice", avatarUrl: avatarURL)
        let domain = dto.toDomain()
        
        XCTAssertEqual(domain.login, "alice")
        XCTAssertEqual(domain.avatarUrl, avatarURL)
    }

    // RepositoryDTO.toDomain() maps all fields.
    func test_repositoryDTO_toDomain_mapsAllFields() {
        let dto = makeRepoDTO()
        let domain = dto.toDomain()
        
        XCTAssertEqual(domain.id, dto.id)
        XCTAssertEqual(domain.name, dto.name)
        XCTAssertEqual(domain.fullName, dto.fullName)
        XCTAssertEqual(domain.description, dto.description)
        XCTAssertEqual(domain.stargazersCount, dto.stargazersCount)
        XCTAssertEqual(domain.forksCount, dto.forksCount)
        XCTAssertEqual(domain.language, dto.language)
        XCTAssertEqual(domain.htmlUrl, dto.htmlUrl)
        XCTAssertEqual(domain.owner.login, dto.owner.login)
    }
    
    // nil description is preserved through mapping.
    func test_repositoryDTO_toDomain_nilDescription() {
        let dto = makeRepoDTO(description: nil)
        XCTAssertNil(dto.toDomain().description)
    }
    
    // nil language is preserved through mapping.
    func test_repositoryDTO_toDomain_nilLanguage() {
        let dto = makeRepoDTO(language: nil)
        XCTAssertNil(dto.toDomain().language)
    }
}
