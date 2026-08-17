// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
// 
//  AuthError.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Domain errors related to authentication.
public enum AuthError: Error {
    /// The user explicitly cancelled the authentication flow.
    case userCancelled
    /// A network or connectivity issue occurred during authentication.
    case networkError
    /// An unknown or unexpected error occurred.
    case unknown
}
