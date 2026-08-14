// 
//  CryptedWrapper.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Property wrapper that transparently encrypts and decrypts `String` values
/// when used in `Codable` models.
///
/// The wrapped value is kept in plain text in memory. Whenever the value is
/// encoded or decoded as part of a `Codable` type, it is transformed using
/// the engine configured in `CryptoProvider`.
///
/// Encoding flow:
/// - Takes the plain `String` stored in memory.
/// - Calls `CryptoProvider.encrypt(_:)`.
/// - Encodes the returned `String` directly into the payload.
///
/// Decoding flow:
/// - Reads an encrypted `String` from the payload.
/// - Calls `CryptoProvider.decrypt(_:)`.
/// - Stores the resulting plain `String` in memory.
///
/// - Important: `CryptoProvider` ships with a `DefaultCryptoEngine` that
///   **does not** apply real encryption. It simply returns the input value.
///   You MUST provide your own `CryptoEngine` implementation and configure
///   it via `CryptoProvider.configure(_:)` for production use.
///
/// Example:
///
/// ```swift
/// struct UserInfo: Codable {
///     let name: String
///     @Crypted var email: String
///     @Crypted var password: String
/// }
///
/// // At app startup:
/// struct MyCryptoEngine: CryptoEngine {
///     func encrypt(_ value: String) throws -> String {
///         // TODO: call your real crypto framework here
///     }
///
///     func decrypt(_ value: String) throws -> String {
///         // TODO: call your real crypto framework here
///     }
/// }
///
/// CryptoProvider.configure(MyCryptoEngine())
/// ```
@propertyWrapper
public struct Crypted: Codable, Sendable {

    // MARK: - Stored Value

    private var value: String

    // MARK: - Init

    /// Creates a new `Crypted` wrapper with the given plain value.
    ///
    /// - Parameter wrappedValue: Plain text value to be stored in memory.
    public init(wrappedValue: String) {
        self.value = wrappedValue
    }

    // MARK: - Wrapped Value

    /// Plain text value stored in memory.
    public var wrappedValue: String {
        get { value }
        set { value = newValue }
    }

    // MARK: - Codable

    /// Decodes the encrypted value from the given decoder by:
    /// - reading an encrypted `String` from the payload, and
    /// - delegating to `CryptoProvider.decrypt(_:)` to obtain the plain value.
    ///
    /// - Parameter decoder: Decoder to read the encrypted payload from.
    /// - Throws: A `DecodingError` or any error thrown by the configured
    ///   `CryptoEngine` via `CryptoProvider`.
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let encrypted = try container.decode(String.self)
        let decrypted = try CryptoProvider.decrypt(encrypted)
        self.value = decrypted
    }

    /// Encodes the wrapped value by:
    /// - delegating to `CryptoProvider.encrypt(_:)` to transform the plain
    ///   value, and
    /// - encoding the resulting `String` into the payload.
    ///
    /// - Parameter encoder: Encoder used to serialize the encrypted value.
    /// - Throws: Any error thrown by the configured `CryptoEngine` via
    ///   `CryptoProvider`.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let encrypted = try CryptoProvider.encrypt(value)
        try container.encode(encrypted)
    }
}