// 
//  APIRequest.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Builds `URLRequest` instances from `APIRouter` definitions.
/// This builder composes the final URL using the router's base URL, path, and
/// query items, and applies HTTP method, body and headers.
/// Common defaults (headers, timeout) are applied via `API.configure(_:)`.
public struct APIRequestBuilder {
  
  /// Builds a `URLRequest` for the given API route.
  /// - Parameter route: The endpoint definition conforming to `APIRouter`.
  /// - Returns: A `Result` containing the configured `URLRequest` or a `NetworkError`.
  public static func build(
    for route: APIRouter
  ) -> Result<URLRequest, NetworkError> {
    
    let baseURL = route.baseURL
    
    guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
      return .failure(.invalidURL)
    }
    
    // Compose base path and route path safely.
    let basePath = components.path
    let routePath = route.path
    
    if routePath.isEmpty {
      components.path = basePath
    } else if basePath.hasSuffix("/") {
      components.path = basePath + routePath.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    } else if routePath.hasPrefix("/") {
      components.path = basePath + routePath
    } else {
      components.path = basePath + "/" + routePath
    }
    
    // Apply query items.
    components.queryItems = route.queryItems
    
    guard let url = components.url else {
      return .failure(.invalidURL)
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = route.method.rawValue
    request.httpBody = route.body
    
    // Apply global config (headers, timeout)
    API.configure(&request)
    
    // Apply endpoint-specific headers
    if let extraHeaders = route.headers {
      extraHeaders.forEach { key, value in
        request.setValue(value, forHTTPHeaderField: key)
      }
    }
    
    return .success(request)
  }
}