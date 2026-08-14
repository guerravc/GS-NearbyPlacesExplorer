// 
//  CryptoEngine.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation
import os

/// Defines the contract for a cryptographic engine used by the application.
///
/// A `CryptoEngine` is responsible for transforming plain `String` values
/// into an encrypted representation and back to their original form.
/// The concrete implementation can use any strategy:
///
/// - Symmetric encryption (e.g. AES)
/// - Asymmetric encryption (e.g. RSA)
/// - Multi-layer encryption (e.g. chaining several engines)
///
/// This protocol intentionally works at the `String` level so higher-level
/// components (such as `@Crypted` property wrappers) remain simple and do
/// not need to deal with encoding or binary formats.
///
/// You are expected to provide your own implementation that delegates to
/// your preferred crypto framework.
public protocol CryptoEngine: Sendable {
    /// Encrypts the given plain text value.
    ///
    /// - Parameter value: Plain text to be encrypted.
    /// - Returns: Encrypted representation of the input.
    /// - Throws: An error if the encryption operation fails.
    func encrypt(_ value: String) throws -> String

    /// Decrypts the given encrypted value.
    ///
    /// - Parameter value: Encrypted representation.
    /// - Returns: Decrypted plain text.
    /// - Throws: An error if the decryption operation fails.
    func decrypt(_ value: String) throws -> String
}

/// Central access point for the application's cryptographic engine.
///
/// `CryptoProvider` holds a single `CryptoEngine` instance that is used
/// across the app. By default it uses `DefaultCryptoEngine`, which does
/// **not** apply any real cryptography and simply returns the input value.
/// This allows the template to compile and run without configuration.
///
/// You are expected to:
/// - Provide your own type conforming to `CryptoEngine`.
/// - Configure it at app startup using `CryptoProvider.configure(_:)`.
///
/// Example:
///
/// ```swift
/// struct MyProjectCryptoEngine: CryptoEngine {
///     func encrypt(_ value: String) throws -> String {
///         // TODO: Apply your real encryption logic here,
///         //       for example using CryptoKit or a third-party framework.
///     }
///
///     func decrypt(_ value: String) throws -> String {
///         // TODO: Apply your real decryption logic here.
///     }
/// }
///
/// // At app startup:
/// CryptoProvider.configure(MyProjectCryptoEngine())
/// ```
///
/// High-level APIs such as the `@Crypted` property wrapper should call
/// `CryptoProvider.encrypt(_:)` and `CryptoProvider.decrypt(_:)` instead of
/// talking to the engine directly.
public enum CryptoProvider {

    // MARK: - Storage

    /// Thread-safe storage for the configured engine instance.
    /// Defaults to `DefaultCryptoEngine`, which performs no real encryption.
    private static let engineLock = OSAllocatedUnfairLock<CryptoEngine>(
        initialState: DefaultCryptoEngine()
    )

    // MARK: - Configuration

    /// Configures the global cryptographic engine.
    ///
    /// Call this once during application startup to install your own
    /// `CryptoEngine` implementation.
    ///
    /// - Parameter newEngine: Engine responsible for encrypting and
    ///   decrypting sensitive values.
    public static func configure(_ newEngine: CryptoEngine) {
        engineLock.withLock { $0 = newEngine }
    }

    // MARK: - High-level API

    /// Encrypts the given plain text value using the configured engine.
    ///
    /// - Parameter value: Plain text to be encrypted.
    /// - Returns: Encrypted representation of the input.
    /// - Throws: Any error thrown by the underlying engine.
    @discardableResult
    public static func encrypt(_ value: String) throws -> String {
        let engine = engineLock.withLock { $0 }
        return try engine.encrypt(value)
    }

    /// Decrypts the given encrypted value using the configured engine.
    ///
    /// - Parameter value: Encrypted representation.
    /// - Returns: Decrypted plain text.
    /// - Throws: Any error thrown by the underlying engine.
    @discardableResult
    public static func decrypt(_ value: String) throws -> String {
        let engine = engineLock.withLock { $0 }
        return try engine.decrypt(value)
    }
}

/// Default crypto engine used by `CryptoProvider` when no custom engine
/// has been configured.
///
/// - Important: This implementation does **not** provide real security.
///   It simply returns the input value unchanged. Its only purpose is to
///   allow the template to compile and run out of the box.
///
/// You MUST replace this with your own implementation in production code.
struct DefaultCryptoEngine: CryptoEngine {

    /// Default encryption implementation.
    ///
    /// - Note: This method currently returns the input value unchanged.
    ///   Replace the body with your encryption logic or delegate to your
    ///   preferred crypto framework.
    func encrypt(_ value: String) throws -> String {
        // TODO: Implement your encryption logic here.
        // Example skeleton:
        //
        // 1. Convert `value` to `Data` if needed.
        // 2. Apply your cipher algorithm (AES, RSA, etc.).
        // 3. Return a String representation (e.g. Base64 or hex).
        //
        // For now, the template returns the plain value without encryption.
        return value
    }

    /// Default decryption implementation.
    ///
    /// - Note: This method currently returns the input value unchanged.
    ///   Replace the body with your decryption logic or delegate to your
    ///   preferred crypto framework.
    func decrypt(_ value: String) throws -> String {
        // TODO: Implement your decryption logic here.
        // Example skeleton:
        //
        // 1. Interpret `value` according to your chosen format
        //    (e.g. Base64, hex, etc.).
        // 2. Apply the inverse cipher algorithm.
        // 3. Convert the decrypted bytes back to a `String`.
        //
        // For now, the template assumes the input is already plain text.
        return value
    }
}