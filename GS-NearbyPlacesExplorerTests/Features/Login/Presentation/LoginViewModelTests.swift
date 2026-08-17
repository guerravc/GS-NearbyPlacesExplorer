// 
//  LoginViewModelTests.swift
//  GS-NearbyPlacesExplorerTests
//
//  Created by Carlos Lopez on 14/08/26.
//

import XCTest
@testable import GS_NearbyPlacesExplorer

/// Unit tests for `LoginViewModel`.
@MainActor
final class LoginViewModelTests: XCTestCase {
    
    // MARK: - Mocks
    
    struct MockSignInUC: SignInUC {
        var resultToReturn: Result<LoginEntity, Error>
        
        nonisolated func execute(_ input: Any) async -> Result<LoginEntity, Error> {
            return resultToReturn
        }
    }
    
    struct MockRestoreSignInUC: RestoreSignInUC {
        var resultToReturn: Result<LoginEntity, Error>
        
        nonisolated func execute() async -> Result<LoginEntity, Error> {
            return resultToReturn
        }
    }

    struct MockHasStoredSessionUC: HasStoredSessionUC {
        var hasStoredSession: Bool

        nonisolated func execute() async -> Result<Bool, Error> {
            .success(hasStoredSession)
        }
    }
    
    // MARK: - Tests
    
    func test_signIn_success_updatesStateAndRoutesAfterDelay() async {
        let profile = LoginEntity(id: "1", name: "Test", email: "test@test.com", profileImageURL: nil)
        let signInUC = MockSignInUC(resultToReturn: .success(profile))
        let restoreUC = MockRestoreSignInUC(resultToReturn: .failure(AuthError.unknown))
        let router = AppRouter()
        
        let sut = LoginViewModel(router: router)
        sut.signInUC = signInUC
        sut.hasStoredSessionUC = MockHasStoredSessionUC(hasStoredSession: false)
        sut.restoreSignInUC = restoreUC
        
        await sut.signIn(presentingViewController: UIViewController())
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showError)
        XCTAssertTrue(sut.isAuthenticated)
        XCTAssertEqual(sut.userProfile, profile)
        XCTAssertEqual(router.root, .main)
    }
    
    func test_signIn_userCancelled_doesNotShowError() async {
        let signInUC = MockSignInUC(resultToReturn: .failure(AuthError.userCancelled))
        let restoreUC = MockRestoreSignInUC(resultToReturn: .failure(AuthError.unknown))
        let router = AppRouter()
        
        let sut = LoginViewModel(router: router)
        sut.signInUC = signInUC
        sut.hasStoredSessionUC = MockHasStoredSessionUC(hasStoredSession: false)
        sut.restoreSignInUC = restoreUC
        
        await sut.signIn(presentingViewController: UIViewController())
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.showError)
        XCTAssertNil(sut.errorMessage)
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(router.root, .login)
    }
    
    func test_signIn_networkError_showsNetworkErrorMessage() async {
        let signInUC = MockSignInUC(resultToReturn: .failure(AuthError.networkError))
        let restoreUC = MockRestoreSignInUC(resultToReturn: .failure(AuthError.unknown))
        let router = AppRouter()
        
        let sut = LoginViewModel(router: router)
        sut.signInUC = signInUC
        sut.hasStoredSessionUC = MockHasStoredSessionUC(hasStoredSession: false)
        sut.restoreSignInUC = restoreUC
        
        await sut.signIn(presentingViewController: UIViewController())
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Error de red. Inténtalo de nuevo.")
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(router.root, .login)
    }
    
    func test_signIn_keychainWriteFailure_showsErrorMessage() async {
        let keychainError = NSError(domain: "Keychain", code: -50, userInfo: nil)
        let signInUC = MockSignInUC(resultToReturn: .failure(keychainError))
        let restoreUC = MockRestoreSignInUC(resultToReturn: .failure(AuthError.unknown))
        let router = AppRouter()
        
        let sut = LoginViewModel(router: router)
        sut.signInUC = signInUC
        sut.hasStoredSessionUC = MockHasStoredSessionUC(hasStoredSession: false)
        sut.restoreSignInUC = restoreUC
        
        await sut.signIn(presentingViewController: UIViewController())
        
        XCTAssertFalse(sut.isLoading)
        XCTAssertTrue(sut.showError)
        XCTAssertEqual(sut.errorMessage, "Ocurrió un error desconocido.")
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertEqual(router.root, .login)
    }
    
    func test_checkExistingSession_success_routesToMain() async {
        let profile = LoginEntity(id: "1", name: "Test", email: "test@test.com", profileImageURL: nil)
        let signInUC = MockSignInUC(resultToReturn: .failure(AuthError.unknown))
        let restoreUC = MockRestoreSignInUC(resultToReturn: .success(profile))
        let router = AppRouter()
        
        let sut = LoginViewModel(router: router)
        sut.signInUC = signInUC
        sut.hasStoredSessionUC = MockHasStoredSessionUC(hasStoredSession: true)
        sut.restoreSignInUC = restoreUC
        
        await sut.checkExistingSession()
        
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.userProfile, profile)
        XCTAssertEqual(router.root, .main)
    }
    
    func test_checkExistingSession_failure_doesNotRoute() async {
        let signInUC = MockSignInUC(resultToReturn: .failure(AuthError.unknown))
        let restoreUC = MockRestoreSignInUC(resultToReturn: .failure(AuthError.unknown))
        let router = AppRouter()
        
        let sut = LoginViewModel(router: router)
        sut.signInUC = signInUC
        sut.hasStoredSessionUC = MockHasStoredSessionUC(hasStoredSession: true)
        sut.restoreSignInUC = restoreUC
        
        await sut.checkExistingSession()
        
        XCTAssertFalse(sut.isAuthenticated)
        XCTAssertNil(sut.userProfile)
        XCTAssertEqual(router.root, .login)
    }

    func test_checkExistingSession_withoutStoredSession_staysIdle() async {
        let signInUC = MockSignInUC(resultToReturn: .failure(AuthError.unknown))
        let restoreUC = MockRestoreSignInUC(resultToReturn: .success(LoginEntity(id: "1", name: "Test", email: "test@test.com", profileImageURL: nil)))
        let router = AppRouter()

        let sut = LoginViewModel(router: router)
        sut.signInUC = signInUC
        sut.hasStoredSessionUC = MockHasStoredSessionUC(hasStoredSession: false)
        sut.restoreSignInUC = restoreUC

        await sut.checkExistingSession()

        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.userProfile)
        XCTAssertEqual(router.root, .login)
    }
}
