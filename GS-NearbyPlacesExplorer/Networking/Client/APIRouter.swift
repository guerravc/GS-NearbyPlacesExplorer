// 
//  APIRouter.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Describes the type of authorization required by an endpoint.
/// This information can be used by the request builder or dispatcher
/// to apply the appropriate Authorization header.
public enum AuthorizationType: Sendable {
  /// No authorization is required.
  case none
  /// Bearer token authorization (e.g., "Bearer &lt;token&gt;").
  case bearer
  /// Basic authorization (e.g., "Basic &lt;base64(username:password)&gt;").
  case basic
  /// Custom authorization. The dispatcher or middleware is responsible
  /// for deciding how to provide and apply the authorization value.
  case custom
}

/// Describes the information required to build an HTTP request for a specific API endpoint.
/// Types conforming to this protocol should represent concrete endpoints (for example,
/// an `enum` with one case per endpoint).
public protocol APIRouter {
  /// Base URL used for the endpoint (for example, https://api.example.com/v1).
  /// - Note: The default implementation returns `AppConfiguration.apiBaseURL`.
  var baseURL: URL { get }
  
  /// The path component appended to the base URL (for example, "/users" or "/users/{id}").
  var path: String { get }
  
  /// The HTTP method used by the endpoint.
  var method: HTTPMethod { get }
  
  /// Optional query items to be added to the URL.
  var queryItems: [URLQueryItem]? { get }
  
  /// Optional HTTP body data for the request.
  var body: Data? { get }
  
  /// Additional headers specific to the endpoint.
  /// These values are merged on top of the default headers provided by `HTTPConfiguration`.
  var headers: [String: String]? { get }
  
  /// The type of authorization required by the endpoint.
  /// - Note: The dispatcher or middleware is responsible for resolving and
  ///   applying any required token or credentials.
  var authorizationType: AuthorizationType { get }
}

// MARK: - Default Implementations

public extension APIRouter {
  /// Default base URL for all endpoints, obtained from `AppConfiguration`.
  var baseURL: URL {
    AppConfiguration.apiBaseURL
  }
  
  /// Default query items (none).
  var queryItems: [URLQueryItem]? {
    nil
  }
  
  /// Default HTTP body (none).
  var body: Data? {
    nil
  }
  
  /// Default endpoint-specific headers (none).
  var headers: [String: String]? {
    nil
  }
  
  /// Default authorization type (no authorization).
  var authorizationType: AuthorizationType {
    .none
  }
}