// 
//  LoginStorage.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Keychain-backed implementation of the local data source for authentication.
public final class LoginStorage: LoginLocalDataSource {
    
    /// The keychain key used to store the auth token.
    private let tokenKey = "auth_token"
    
    /// Initializes a new instance of `LoginStorage`.
    public init() {}
    
    /// Saves the given token securely to the Keychain.
    /// - Parameter token: The authentication token string.
    /// - Throws: `AuthError.unknown` if saving to the Keychain fails.
    public func saveToken(_ token: String) throws {
        let tokenData = Data(token.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: tokenData
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            throw AuthError.unknown
        }
    }
    
    /// Loads the stored token from the Keychain.
    /// - Returns: The token string if it exists, otherwise `nil`.
    /// - Throws: None, returns `nil` for fetch failures.
    public func getToken() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess else {
            return nil
        }
        
        guard let tokenData = item as? Data,
              let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        
        return token
    }
    
    /// Deletes the stored token from the Keychain.
    /// - Throws: `AuthError.unknown` if deleting the token from Keychain fails.
    public func deleteToken() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tokenKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            throw AuthError.unknown
        }
    }
}
