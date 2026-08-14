// 
//  APIRequestDispatcher.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// Provides access tokens for a given authorization type and route.
/// Implementations can pull tokens from configuration, Keychain, memory, etc.
public protocol AuthTokenProviding: Sendable {
  /// Returns a token for the given authorization type and route.
  /// - Parameters:
  ///   - type: Authorization type requested by the endpoint.
  ///   - route: Endpoint definition.
  /// - Returns: A raw token value or `nil` if no token is available.
  func token(for type: AuthorizationType, route: APIRouter) -> String?
}

/// Describes the operations supported by the networking dispatcher.
/// It can perform regular HTTP requests and server-sent events (SSE) streams.
public protocol APIRequestDispatching: Sendable {
  /// Performs a one-shot HTTP request for the given route.
  /// - Parameter route: Endpoint definition.
  /// - Returns: A result containing an `APIResponse` on success or a `NetworkError` on failure.
  func perform(_ route: APIRouter) async -> Result<APIResponse, NetworkError>

  /// Starts a server-sent events (SSE) stream for the given route.
  /// The stream yields decoded values of the requested type.
  ///
  /// The generic type `T` is inferred from the call site, for example:
  ///
  /// ```swift
  /// let result: Result<AsyncStream<EventDTO>, NetworkError> =
  ///   await dispatcher.stream(EventsAPI.subscribe)
  /// ```
  ///
  /// - Parameter route: Endpoint definition.
  /// - Returns: A result containing an `AsyncStream` of decoded values on success
  ///   or a `NetworkError` if the stream cannot be started.
  func stream<T: Decodable>(
    _ route: APIRouter
  ) async -> Result<AsyncStream<T>, NetworkError>
}

/// Default implementation of `APIRequestDispatching` backed by `URLSession`.
/// This dispatcher uses `APIRequestBuilder` to create requests, applies authorization
/// metadata from `AuthorizationType`, and handles both one-shot and streaming requests.
public final class APIRequestDispatcher: APIRequestDispatching, @unchecked Sendable {

  /// Underlying URLSession used to perform network requests.
  private let session: URLSession
  /// Optional token provider used to resolve authorization credentials.
  private let authProvider: AuthTokenProviding?
  /// JSON decoder used for SSE event decoding, ensuring consistency with `APIClient`.
  private let decoder: JSONDecoder
  /// Maximum allowed buffer size for streaming responses, in bytes.
  private let maxStreamBufferBytes: Int

  /// Creates a new dispatcher instance.
  /// - Parameters:
  ///   - session: URLSession used for requests. Defaults to `.shared`.
  ///   - authProvider: Optional provider used to obtain auth tokens.
  ///   - decoder: JSON decoder for SSE events. Defaults to `JSONDecoder()`.
  ///   - maxStreamBufferBytes: Maximum buffer size for SSE processing. Defaults to 4 MB.
  public init(
    session: URLSession = .shared,
    authProvider: AuthTokenProviding? = nil,
    decoder: JSONDecoder = JSONDecoder(),
    maxStreamBufferBytes: Int = 4 * 1024 * 1024
  ) {
    self.session = session
    self.authProvider = authProvider
    self.decoder = decoder
    self.maxStreamBufferBytes = maxStreamBufferBytes
  }

  // MARK: - One-shot requests

  /// Performs a one-shot HTTP request for the given route.
  /// - Parameter route: Endpoint definition.
  /// - Returns: A result containing an `APIResponse` on success or a `NetworkError` on failure.
  public func perform(_ route: APIRouter) async -> Result<APIResponse, NetworkError> {
    switch APIRequestBuilder.build(for: route) {
    case .failure(let error):
      return .failure(error)
    case .success(var request):
      applyAuthorization(for: route, to: &request)

      do {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
          return .failure(.unknown)
        }

        let apiResponse = APIResponse(data: data, urlResponse: httpResponse)

        if let status = apiResponse.httpStatus {
          if status.isSuccessful {
            return .success(apiResponse)
          } else {
            return .failure(.serverError(statusCode: status, data: data))
          }
        } else {
          return .failure(.unacceptableStatusCode(apiResponse.statusCode, data))
        }
      } catch let error as URLError where error.code == .cancelled {
        return .failure(.cancelled)
      } catch {
        return .failure(.transportError(error))
      }
    }
  }

  // MARK: - Streaming (SSE)

  /// Starts a server-sent events (SSE) stream for the given route.
  /// The stream yields decoded values of the inferred generic type `T`.
  ///
  /// - Parameter route: Endpoint definition.
  /// - Returns: A result containing an `AsyncStream` of decoded values on success
  ///   or a `NetworkError` if the stream cannot be started.
  public func stream<T: Decodable>(
    _ route: APIRouter
  ) async -> Result<AsyncStream<T>, NetworkError> {

    let requestResult = APIRequestBuilder.build(for: route)

    guard case .success(var request) = requestResult else {
      if case .failure(let error) = requestResult {
        return .failure(error)
      }
      return .failure(.invalidURL)
    }

    applyAuthorization(for: route, to: &request)
    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")

    do {
      let (bytes, response) = try await session.bytes(for: request)
      guard let httpResponse = response as? HTTPURLResponse else {
        return .failure(.unknown)
      }

      if let status = HTTPStatusCode(rawValue: httpResponse.statusCode), !status.isSuccessful {
        return .failure(.serverError(statusCode: status, data: nil))
      }

      let eventDecoder = decoder
      let bufferLimit = maxStreamBufferBytes
      let delimiter = Data("\n\n".utf8)
      let lineSeparator: Character = "\n"
      let suffixCharacter: Character = "\r"
      let dataPrefix = "data:"

      var buffer = Data()

      let (stream, continuation) = AsyncStream<T>.makeStream()

      let task = Task {
        do {
          for try await chunk in bytes {
            buffer.append(chunk)

            if buffer.count > bufferLimit {
              assertionFailure(
                "SSE buffer exceeded \(bufferLimit) bytes. Stream terminated to prevent memory exhaustion."
              )
              continuation.finish()
              break
            }

            while let range = buffer.range(of: delimiter) {
              let eventData = buffer.subdata(in: buffer.startIndex ..< range.lowerBound)
              buffer.removeSubrange(buffer.startIndex ..< range.upperBound)

              guard let eventText = String(data: eventData, encoding: .utf8) else { continue }

              let lines = eventText.split(separator: lineSeparator, omittingEmptySubsequences: false)

              let dataLines: [String] = lines.compactMap { line in
                var singleLine = String(line)

                if singleLine.last == suffixCharacter {
                  singleLine.removeLast()
                }

                if singleLine.hasPrefix(dataPrefix) {
                  let value = singleLine.dropFirst(dataPrefix.count)
                  return value.trimmingCharacters(in: .whitespaces)
                }

                return nil
              }

              let joined = dataLines.joined(separator: String(lineSeparator))
              guard let jsonData = joined.data(using: .utf8), !jsonData.isEmpty else { continue }

              do {
                let value = try eventDecoder.decode(T.self, from: jsonData)
                continuation.yield(value)
              } catch {
                #if DEBUG
                print("[SSE] Failed to decode event of type \(T.self): \(error)")
                #endif
                continue
              }
            }
          }
          continuation.finish()
        } catch is CancellationError {
          continuation.finish()
        } catch {
          continuation.finish()
        }
      }

      continuation.onTermination = { _ in
        task.cancel()
      }

      return .success(stream)
    } catch let error as URLError where error.code == .cancelled {
      return .failure(.cancelled)
    } catch {
      return .failure(.transportError(error))
    }
  }

  // MARK: - Private helpers

  /// Applies authorization metadata to the given request based on the route's
  /// `authorizationType` and the available token provider or configuration.
  /// - Parameters:
  ///   - route: Endpoint definition.
  ///   - request: Request instance to mutate.
  private func applyAuthorization(
    for route: APIRouter,
    to request: inout URLRequest
  ) {
    switch route.authorizationType {
    case .none:
      return
    case .bearer:
      let token = authProvider?.token(for: .bearer, route: route)
        ?? AppConfiguration.apiPersonalAccessToken
      guard let token else { return }
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    case .basic:
      guard let token = authProvider?.token(for: .basic, route: route) else { return }
      request.setValue("Basic \(token)", forHTTPHeaderField: "Authorization")
    case .custom:
      guard let token = authProvider?.token(for: .custom, route: route) else { return }
      request.setValue(token, forHTTPHeaderField: "Authorization")
    }
  }
}
