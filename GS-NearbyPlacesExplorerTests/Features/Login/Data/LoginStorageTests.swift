// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
// 
//  LoginStorageTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Lopez on 14/08/26.
//

import XCTest
@testable import GS_NearbyPlacesExplorer

/// Unit tests for `LoginStorage`.
final class LoginStorageTests: XCTestCase {
    
    var sut: LoginStorage!
    
    override func setUp() {
        super.setUp()
        sut = LoginStorage()
        try? sut.deleteToken() // Start with a clean state
    }
    
    override func tearDown() {
        try? sut.deleteToken()
        sut = nil
        super.tearDown()
    }
    
    func test_saveToken_readsSuccessfully() throws {
        let testToken = "test_token_123"
        try sut.saveToken(testToken)
        
        let retrievedToken = try sut.getToken()
        
        XCTAssertEqual(retrievedToken, testToken)
    }
    
    func test_deleteToken_removesTokenSuccessfully() throws {
        let testToken = "test_token_123"
        try sut.saveToken(testToken)
        
        try sut.deleteToken()
        let retrievedToken = try sut.getToken()
        
        XCTAssertNil(retrievedToken)
    }
    
    func test_getToken_whenEmpty_returnsNil() throws {
        let retrievedToken = try sut.getToken()
        
        XCTAssertNil(retrievedToken)
    }
}
