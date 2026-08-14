// 
//  HTTPTypes.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Represents the supported HTTP methods for requests.
public enum HTTPMethod: String, Sendable {
  /// The GET method requests a representation of the specified resource.
  case get = "GET"
  /// The POST method is used to submit an entity to the specified resource.
  case post = "POST"
  /// The PUT method replaces all current representations of the target resource.
  case put = "PUT"
  /// The DELETE method deletes the specified resource.
  case delete = "DELETE"
  /// The PATCH method is used to apply partial modifications to a resource.
  case patch = "PATCH"
  /// The HEAD method asks for a response identical to a GET request, but without the response body.
  case head = "HEAD"
  /// The OPTIONS method is used to describe the communication options for the target resource.
  case options = "OPTIONS"
}

/// Represents a subset of HTTP status codes commonly used in client applications.
public enum HTTPStatusCode: Int, Sendable {
  // MARK: Informational (1xx)
  
  /// The server has received the request headers and the client should proceed to send the request body.
  case `continue` = 100
  
  // MARK: Success (2xx)
  
  /// Standard response for successful HTTP requests.
  case ok = 200
  /// The request has been fulfilled, resulting in the creation of a new resource.
  case created = 201
  /// The request has been accepted for processing, but the processing has not been completed.
  case accepted = 202
  /// The server successfully processed the request and is not returning any content.
  case noContent = 204
  
  // MARK: Redirection (3xx)
  
  /// The request has more than one possible response.
  case multipleChoices = 300
  /// This and all future requests should be directed to the given URI.
  case movedPermanently = 301
  /// The URI of requested resource has been changed temporarily.
  case found = 302
  /// The response can be found under another URI using a GET method.
  case seeOther = 303
  /// The resource has not been modified since last requested.
  case notModified = 304
  
  // MARK: Client Error (4xx)
  
  /// The server cannot or will not process the request due to an apparent client error.
  case badRequest = 400
  /// Authentication is required and has failed or has not yet been provided.
  case unauthorized = 401
  /// The request was valid, but the server is refusing action.
  case forbidden = 403
  /// The requested resource could not be found.
  case notFound = 404
  /// The request could not be processed because of conflict in the request.
  case conflict = 409
  /// The user has sent too many requests in a given amount of time.
  case tooManyRequests = 429
  
  // MARK: Server Error (5xx)
  
  /// A generic error message, given when no more specific message is suitable.
  case internalServerError = 500
  /// The server was acting as a gateway or proxy and received an invalid response.
  case badGateway = 502
  /// The server is currently unavailable (overloaded or down).
  case serviceUnavailable = 503
  /// The server was acting as a gateway or proxy and did not receive a timely response.
  case gatewayTimeout = 504
  
  // MARK: Response type
  
  /// High-level classification of HTTP status codes.
  public enum ResponseType {
    /// 1xx: Informational.
    case informational
    /// 2xx: Success.
    case success
    /// 3xx: Redirection.
    case redirection
    /// 4xx: Client error.
    case clientError
    /// 5xx: Server error.
    case serverError
    /// Any other code.
    case undefined
  }
  
  /// The response type derived from the status code value.
  public var responseType: ResponseType {
    switch rawValue {
    case 100..<200:
      return .informational
    case 200..<300:
      return .success
    case 300..<400:
      return .redirection
    case 400..<500:
      return .clientError
    case 500..<600:
      return .serverError
    default:
      return .undefined
    }
  }
  
  /// Indicates whether the status code represents a successful response (2xx).
  public var isSuccessful: Bool {
    responseType == .success
  }
}

/// Represents errors that can occur during networking operations.
public enum NetworkError: Error, @unchecked Sendable {
  /// The URL could not be constructed or is invalid.
  case invalidURL
  /// A low-level transport error occurred (e.g., network connectivity issues).
  case transportError(Error)
  /// The server responded with a non-success status code.
  case serverError(statusCode: HTTPStatusCode, data: Data?)
  /// The response did not contain any data when data was expected.
  case noData
  /// The response data could not be decoded into the expected type.
  case decodingError(Error)
  /// The status code is not mapped to a known `HTTPStatusCode`.
  case unacceptableStatusCode(Int, Data?)
  /// The request was explicitly cancelled by the caller.
  case cancelled
  /// An unknown or unexpected error occurred.
  case unknown
}

extension NetworkError: LocalizedError {
  /// A human-readable description of the error.
  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "The requested URL is invalid."
    case .transportError(let error):
      return error.localizedDescription
    case .serverError(let statusCode, _):
      return "Server responded with status code \(statusCode.rawValue)."
    case .noData:
      return "The response did not contain any data."
    case .decodingError(let error):
      return "Failed to decode response: \(error.localizedDescription)"
    case .unacceptableStatusCode(let code, _):
      return "Received unacceptable status code: \(code)."
    case .cancelled:
      return "The request was cancelled."
    case .unknown:
      return "An unknown networking error occurred."
    }
  }
}

public extension HTTPURLResponse {
  /// Attempts to map the HTTP status code to a `HTTPStatusCode` value.
  var httpStatus: HTTPStatusCode? {
    HTTPStatusCode(rawValue: statusCode)
  }
}