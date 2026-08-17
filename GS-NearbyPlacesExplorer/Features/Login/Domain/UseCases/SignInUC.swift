// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
// 
//  SignInUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Async operation Use Case for logging in the user.
public protocol SignInUC: AsyncOperationUseCase
where Input == Any, Output == LoginEntity { }

/// Default implementation of `SignInUC`.
public final class SignInUCImpl: SignInUC {
    
    /// The injected gateway used to perform authentication tasks.
    @Inject var gateway: LoginGateway

    /// Initializes a new instance of `SignInUCImpl`.
    public init() {}
    
    /// Executes the sign in operation.
    /// - Parameter input: The presenting view controller needed by the authentication SDK.
    /// - Returns: A result containing the authenticated `LoginEntity` or an error.
    public func execute(_ input: Any) async -> Result<LoginEntity, Error> {
        return await gateway.signIn(presenting: input)
    }
}
