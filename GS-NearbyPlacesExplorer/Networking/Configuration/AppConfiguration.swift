// 
//  AppConfiguration.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Provides typed access to networking-related configuration values.
/// These values are expected to be supplied via environment-based Info.plist keys
/// (e.g., Debug.xcconfig, Release.xcconfig).
///
/// Keys such as API_SCHEME, API_HOST, API_BASE_PATH, API_BUCKET_URL,
/// and API_PAT should be defined in the project's build configuration files.
public enum AppConfiguration {
  
  /// Keys expected to exist in the application's Info.plist.
  public enum InfoKey: String {
    case apiScheme         = "API_SCHEME"
    case apiHost           = "API_HOST"
    case apiBasePath       = "API_BASE_PATH"
    case apiBucketURL      = "API_BUCKET_URL"
    case apiPersonalAccessToken = "API_PAT"
  }
  
  /// AppConfiguration-specific error type.
  public enum ConfigurationError: Error, LocalizedError {
    case missingKey(InfoKey)
    case invalidValue(InfoKey)
    
    public var errorDescription: String? {
      switch self {
      case .missingKey(let key):
        return "Missing configuration value for key: \(key.rawValue)"
      case .invalidValue(let key):
        return "Invalid value format for key: \(key.rawValue)"
      }
    }
  }
  
  /// Retrieves and converts a value from the Info.plist.
  /// - Parameters:
  ///   - key: The configuration key to look up.
  /// - Throws: `ConfigurationError` if the key is missing or has invalid format.
  /// - Returns: A value convertible from `LosslessStringConvertible`.
  public static func value<T>(for key: InfoKey) throws -> T where T: LosslessStringConvertible {
    guard let object = Bundle.main.object(forInfoDictionaryKey: key.rawValue) else {
      throw ConfigurationError.missingKey(key)
    }
    
    // For URL strings, returning as String is expected.
    if let casted = object as? T {
      return casted
    }
    
    // Attempt LosslessStringConvertible conversion.
    if let string = object as? String, let converted = T(string) {
      return converted
    }
    
    throw ConfigurationError.invalidValue(key)
  }
}

// MARK: - Typed Networking Values
public extension AppConfiguration {
  
  /// Scheme used by the API (e.g., "https").
  static var apiScheme: String {
    (try? value(for: .apiScheme)) ?? "https"
  }
  
  /// Host name of the API (e.g., "api.example.com").
  static var apiHost: String {
    (try? value(for: .apiHost)) ?? ""
  }
  
  /// Base path for the API version (default: "/v1").
  /// - Important: Developers may update this manually if API versioning changes.
  static var apiBasePath: String {
    (try? value(for: .apiBasePath)) ?? "/v1"
  }
  
  /// Full base URL constructed from scheme, host and base path.
  ///
  /// If the URL cannot be built (e.g. missing host in Info.plist), an
  /// `assertionFailure` is raised in DEBUG builds so the misconfiguration
  /// is caught early. In RELEASE builds the fallback URL will cause a clear
  /// server error rather than a silent logic bug.
  static var apiBaseURL: URL {
    var components = URLComponents()
    components.scheme = apiScheme
    components.host = apiHost
    components.path = apiBasePath

    guard let url = components.url, !apiHost.isEmpty else {
      assertionFailure(
        "apiBaseURL could not be constructed. Verify API_SCHEME, API_HOST, and API_BASE_PATH in Info.plist."
      )
      return URL(string: "https://misconfigured.invalid")!
    }

    return url
  }
  
  /// Optional bucket URL (for file uploads, images, etc.).
  static var apiBucketURL: URL? {
    guard let string: String = try? value(for: .apiBucketURL) else { return nil }
    return URL(string: string)
  }
  
  /// Optional Personal Access Token for development/internal features.
  static var apiPersonalAccessToken: String? {
    try? value(for: .apiPersonalAccessToken)
  }
}