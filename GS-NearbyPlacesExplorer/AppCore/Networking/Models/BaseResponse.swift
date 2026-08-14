// 
//  BaseResponse.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

// ADR-003: These response models live in App Core (not in the Networking template)
// so that Use Case and Clean Module templates can depend solely on App Core without
// pulling in the full Networking stack. This keeps the dependency graph shallow:
// Clean Module -> App Core (not Clean Module -> Networking -> App Core).

import Foundation

/// Generic envelope for API responses that wrap a domain value with status and message metadata.
/// This structure is meant to represent the "business" status returned by the backend,
/// even when the HTTP status code is 200.
public struct BaseResponse<Value: Decodable & Sendable>: Decodable, Sendable {
  /// Internal status code returned by the backend.
  public let status: Int
  /// Message associated with the response, typically used for user-facing or log messages.
  public let message: String
  /// Wrapped payload returned by the backend.
  public let object: Value?
  
  /// Indicates whether the response should be considered successful
  /// based on the internal status code.
  public var isSuccessful: Bool {
    status == 0 || (200 ..< 300).contains(status)
  }
  
  /// Creates a new `BaseResponse` instance.
  /// - Parameters:
  ///   - status: Internal status code returned by the backend.
  ///   - message: Message associated with the response.
  ///   - object: Wrapped payload returned by the backend.
  public init(
    status: Int,
    message: String,
    object: Value?
  ) {
    self.status = status
    self.message = message
    self.object = object
  }
  
  private enum CodingKeys: String, CodingKey {
    case status
    case message
    case object
  }
}

/// Represents an empty payload for responses that do not return a body.
/// This type is useful when the backend still wraps the response in a `BaseResponse`
/// but there is no meaningful data to decode.
public struct EmptyResponseBody: Codable, Sendable {
  /// Creates a new instance of `EmptyResponseBody`.
  public init() { }
}

/// Convenience alias for responses that use `EmptyResponseBody` as their payload.
public typealias EmptyBaseResponse = BaseResponse<EmptyResponseBody>

/// Represents an error payload returned by the backend.
/// This type can be used either as a direct model or as a payload inside `BaseResponse`.
public struct ErrorResponse: Decodable, Sendable, Error {
  /// Internal status code describing the error.
  public let status: Int
  /// Human-readable message describing the error.
  public let message: String
  /// Optional error code returned by the backend.
  public let code: String?
  
  /// Creates a new `ErrorResponse` instance.
  /// - Parameters:
  ///   - status: Internal status code describing the error.
  ///   - message: Human-readable message describing the error.
  ///   - code: Optional error code returned by the backend.
  public init(
    status: Int,
    message: String,
    code: String? = nil
  ) {
    self.status = status
    self.message = message
    self.code = code
  }
}