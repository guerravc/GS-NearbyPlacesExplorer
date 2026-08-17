// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
// 
//  SignInUCTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Lopez on 14/08/26.
//

import XCTest
@testable import GS_NearbyPlacesExplorer

// MARK: - Mocks

struct MockLoginGateway: LoginGateway {
    var signInResultToReturn: Result<LoginEntity, Error>
    var restoreSignInResultToReturn: Result<LoginEntity, Error>
    var hasStoredSessionToReturn = false

    func hasStoredSession() -> Bool {
        hasStoredSessionToReturn
    }
    
    func signIn(presenting: Any) async -> Result<LoginEntity, Error> {
        return signInResultToReturn
    }
    
    func restoreSignIn() async -> Result<LoginEntity, Error> {
        return restoreSignInResultToReturn
    }
}

/// Unit tests for the authentication use cases.
@MainActor
final class SignInUCTests: XCTestCase {
    
    // MARK: - Tests for SignInUC
    
    func test_SignInUC_success() async {
        let profile = LoginEntity(id: "1", name: "Test", email: "test@test.com", profileImageURL: nil)
        let gateway = MockLoginGateway(signInResultToReturn: .success(profile), restoreSignInResultToReturn: .failure(AuthError.unknown))
        let sut = SignInUCImpl()
        sut.gateway = gateway
        
        let result = await sut.execute(UIViewController())
        
        switch result {
        case .success(let returnedProfile):
            XCTAssertEqual(returnedProfile, profile)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func test_SignInUC_failure() async {
        let gateway = MockLoginGateway(signInResultToReturn: .failure(AuthError.userCancelled), restoreSignInResultToReturn: .failure(AuthError.unknown))
        let sut = SignInUCImpl()
        sut.gateway = gateway
        
        let result = await sut.execute(UIViewController())
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error as? AuthError, AuthError.userCancelled)
        }
    }
    
    // MARK: - Tests for RestoreSignInUC
    
    func test_RestoreSignInUC_success() async {
        let profile = LoginEntity(id: "1", name: "Test", email: "test@test.com", profileImageURL: nil)
        let gateway = MockLoginGateway(signInResultToReturn: .failure(AuthError.unknown), restoreSignInResultToReturn: .success(profile))
        let sut = RestoreSignInUCImpl()
        sut.gateway = gateway
        
        let result = await sut.execute()
        
        switch result {
        case .success(let returnedProfile):
            XCTAssertEqual(returnedProfile, profile)
        case .failure:
            XCTFail("Expected success but got failure")
        }
    }
    
    func test_RestoreSignInUC_failure() async {
        let gateway = MockLoginGateway(signInResultToReturn: .failure(AuthError.unknown), restoreSignInResultToReturn: .failure(AuthError.networkError))
        let sut = RestoreSignInUCImpl()
        sut.gateway = gateway
        
        let result = await sut.execute()
        
        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            XCTAssertEqual(error as? AuthError, AuthError.networkError)
        }
    }

    func test_HasStoredSessionUC_returnsGatewayValue() async {
        let gateway = MockLoginGateway(
            signInResultToReturn: .failure(AuthError.unknown),
            restoreSignInResultToReturn: .failure(AuthError.unknown),
            hasStoredSessionToReturn: true
        )
        let sut = HasStoredSessionUCImpl()
        sut.gateway = gateway

        let result = await sut.execute()

        XCTAssertEqual(try? result.get(), true)
    }
}
