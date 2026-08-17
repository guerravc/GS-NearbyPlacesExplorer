// 
//  RestoreSignInUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Async query Use Case for restoring an existing session.
public protocol RestoreSignInUC: AsyncQueryUseCase
where Output == LoginEntity { }

/// Default implementation of `RestoreSignInUC`.
public final class RestoreSignInUCImpl: RestoreSignInUC {
    
    /// The injected gateway used to perform authentication tasks.
    @Inject var gateway: LoginGateway
    
    /// Initializes a new instance of `RestoreSignInUCImpl`.
    public init() {}
    
    /// Executes the session restoration.
    /// - Returns: A result containing the authenticated `LoginEntity` or an error.
    public func execute() async -> Result<LoginEntity, Error> {
        return await gateway.restoreSignIn()
    }
}
