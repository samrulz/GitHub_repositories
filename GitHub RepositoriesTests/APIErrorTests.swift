//
//  APIErrorTests.swift
//  GitHub RepositoriesTests
//
//  Created by Sandip Musale on 18/02/26.
//

import XCTest
@testable import GitHub_Repositories

final class APIErrorTests: XCTestCase {
    
    // invalidResponse error description.
    func test_invalidResponse_errorDescription() {
        let error = APIError.invalidResponse
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.lowercased().contains("invalid"))
    }
    
    // httpStatus error description includes the code.
    func test_httpStatus_errorDescription_includesCode() {
        let error = APIError.httpStatus(404)
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.contains("404"))
    }
    
    // decodingFailed error description.
    func test_decodingFailed_errorDescription() {
        let error = APIError.decodingFailed
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription!.lowercased().contains("decode") ||
                      error.errorDescription!.lowercased().contains("decod"))
    }
    
    // Different status codes produce different descriptions.
    func test_httpStatus_differentCodes_differentDescriptions() {
        XCTAssertNotEqual(
            APIError.httpStatus(401).errorDescription,
            APIError.httpStatus(500).errorDescription
        )
    }
}
