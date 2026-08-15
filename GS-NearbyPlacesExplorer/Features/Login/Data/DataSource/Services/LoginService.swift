// 
//  LoginService.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation
import GoogleSignIn

/// Google-backed implementation of the remote data source for authentication.
public final class LoginService: LoginRemoteDataSource {
    
    /// Initializes a new instance of `LoginService`.
    public init() {}

    /// Initiates the Google Sign In flow.
    /// - Parameter presenting: The view controller to present the sign in modal on.
    /// - Returns: A model containing the authenticated user's profile.
    /// - Throws: `AuthError` corresponding to network or cancellation events.
    @MainActor
    public func signIn(presenting: Any) async throws -> LoginModel {
        guard let presentingVC = presenting as? UIViewController else {
            throw AuthError.unknown
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { signInResult, error in
                if let error = error {
                    let nsError = error as NSError
                    if nsError.domain == kGIDSignInErrorDomain && nsError.code == GIDSignInError.canceled.rawValue {
                        continuation.resume(throwing: AuthError.userCancelled)
                    } else {
                        continuation.resume(throwing: AuthError.networkError)
                    }
                    return
                }
                
                guard let user = signInResult?.user,
                      let profile = user.profile else {
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }
                
                let imageURL = profile.hasImage ? profile.imageURL(withDimension: 120) : nil
                
                let dto = LoginModel(
                    id: user.userID ?? UUID().uuidString,
                    name: profile.name,
                    email: profile.email,
                    profileImageURL: imageURL
                )
                
                continuation.resume(returning: dto)
            }
        }
    }

    /// Restores a previous Google Sign In session silently.
    /// - Returns: A model containing the restored user's profile.
    /// - Throws: `AuthError` if the session could not be restored.
    @MainActor
    public func restoreSignIn() async throws -> LoginModel {
        return try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                if error != nil {
                    continuation.resume(throwing: AuthError.networkError)
                    return
                }
                
                guard let user = user,
                      let profile = user.profile else {
                    continuation.resume(throwing: AuthError.unknown)
                    return
                }
                
                let imageURL = profile.hasImage ? profile.imageURL(withDimension: 120) : nil
                
                let dto = LoginModel(
                    id: user.userID ?? UUID().uuidString,
                    name: profile.name,
                    email: profile.email,
                    profileImageURL: imageURL
                )
                
                continuation.resume(returning: dto)
            }
        }
    }
}
