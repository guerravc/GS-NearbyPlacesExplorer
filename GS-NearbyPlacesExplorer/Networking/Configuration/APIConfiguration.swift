// 
//  APIConfiguration.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Represents the supported API versions for the backend.
/// The default version is `.v1`. Developers may update this value manually
/// if the backend version changes.
public enum APIVersion: Int, Sendable {
  /// API version 1.
  case v1 = 1
  
  /// String representation of the version (e.g., "v1").
  public var stringValue: String {
    "v\(rawValue)"
  }
}

/// Describes HTTP configuration values applied to outgoing requests, such as
/// headers and timeout intervals.
public protocol HTTPConfiguration {
  /// Default headers added to every request.
  var headers: [String: String] { get }
  
  /// Default timeout interval for requests.
  var requestTimeoutInterval: TimeInterval { get }
}

public extension HTTPConfiguration {
  /// Default timeout interval (30 seconds).
  var requestTimeoutInterval: TimeInterval {
    30.0
  }
}

/// Default implementation of `HTTPConfiguration` used by the `API` facade.
/// This configuration sets common headers such as API version, app metadata
/// and JSON content negotiation.
public struct DefaultHTTPConfiguration: HTTPConfiguration {
  /// Default headers added to every request.
  public var headers: [String: String] {
    var result: [String: String] = [:]
    
    result["Api-Version"] = APIVersion.current.stringValue
    result["App-Name"] = AppInfo.appName
    result["Platform"] = AppInfo.osName
    result["App-Version"] = AppInfo.shortVersion
    result["Content-Type"] = "application/json"
    result["Accept"] = "application/json"
    
    return result
  }
  
  /// Creates a default HTTP configuration instance.
  public init() { }
}

/// Facade responsible for applying common HTTP configuration to requests.
/// This type centralizes the API version and the active HTTP configuration.
public enum API {
  /// Current API version used by the client.
  /// - Note: Defaults to `.v1`. Update this value if the backend API version changes.
  public static var version: APIVersion = .v1
  
  /// Active HTTP configuration used for all requests.
  /// - Note: You may replace this value at application startup
  ///   (for example, with a custom configuration for testing).
  public static var configuration: HTTPConfiguration = DefaultHTTPConfiguration()
  
  /// Applies common headers and timeout configuration to the given request.
  /// - Parameter request: The request to configure.
  public static func configure(_ request: inout URLRequest) {
    configuration.headers.forEach { key, value in
      request.setValue(value, forHTTPHeaderField: key)
    }
    
    request.timeoutInterval = configuration.requestTimeoutInterval
  }
}

// MARK: - APIVersion current helper

public extension APIVersion {
  /// Current API version used globally.
  /// - Note: This helper simply returns `API.version` to avoid direct coupling
  ///   to the `API` type in other modules.
  static var current: APIVersion {
    API.version
  }
}