// 
//  APIResponse.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Represents a raw HTTP response returned by the networking layer.
/// This type bundles the received data with its associated `HTTPURLResponse`
/// and provides convenient access to status information.
public struct APIResponse {
  /// The raw response data.
  public let data: Data
  
  /// The underlying HTTP response.
  public let urlResponse: HTTPURLResponse
  
  /// Creates a new `APIResponse` instance.
  /// - Parameters:
  ///   - data: The raw response data.
  ///   - urlResponse: The associated HTTP URL response.
  public init(
    data: Data,
    urlResponse: HTTPURLResponse
  ) {
    self.data = data
    self.urlResponse = urlResponse
  }
  
  /// The HTTP status code as an integer.
  public var statusCode: Int {
    urlResponse.statusCode
  }
  
  /// Attempts to map the status code to a `HTTPStatusCode` value.
  public var httpStatus: HTTPStatusCode? {
    urlResponse.httpStatus
  }
  
  /// Indicates whether the response status code represents a successful response (2xx).
  public var isSuccessful: Bool {
    httpStatus?.isSuccessful ?? (200..<300).contains(statusCode)
  }
}