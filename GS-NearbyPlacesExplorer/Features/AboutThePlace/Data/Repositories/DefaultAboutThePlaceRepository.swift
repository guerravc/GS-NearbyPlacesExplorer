// 
//  DefaultAboutThePlaceRepository.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Default repository implementation for the AboutThePlace module.
///
/// This type implements the domain `AboutThePlaceGateway` protocol and
/// coordinates the remote service and local storage layers. It is responsible for:
/// - Calling the remote data source (service) and interpreting `BaseResponse`
///   envelopes returned by the backend.
/// - Mapping DTOs to domain entities.
/// - Optionally caching entities in the local storage.
/// - Mapping infrastructure errors (network, backend) into domain-friendly errors.
public enum AboutThePlaceRepositoryError: Error, @unchecked Sendable {
  /// Represents an error payload returned by the backend.
  case backend(ErrorResponse)
  /// Represents a networking or low-level error.
  case network(Error)
  /// Indicates that the backend response did not contain the expected object.
  case emptyResponseObject
}

/// Default implementation of the module gateway, backed by a remote service
/// and an optional local storage.
public final class DefaultAboutThePlaceRepository: AboutThePlaceGateway {

  // MARK: - Dependencies

  private let remoteDataSource: AboutThePlaceRemoteDataSource
  private let localDataSource: AboutThePlaceLocalDataSource

  // MARK: - Init

  /// Creates a new repository instance.
  ///
  /// - Parameters:
  ///   - remoteDataSource: Remote data source used to perform backend requests.
  ///   - localDataSource: Local data source used to cache or retrieve entities.
  public init(
    remoteDataSource: AboutThePlaceRemoteDataSource,
    localDataSource: AboutThePlaceLocalDataSource
  ) {
    self.remoteDataSource = remoteDataSource
    self.localDataSource = localDataSource
  }

  // MARK: - AboutThePlaceGateway

  /// Fetches data for the given request by delegating to the remote data source
  /// and interpreting the backend `BaseResponse` envelope.
  ///
  /// - Parameter request: Request model to be sent to the backend.
  /// - Returns: A result containing the module response or an error.
  public func fetch(
    _ request: AboutThePlaceRequest
  ) async -> Result<AboutThePlaceResponse, Error> {
    do {
      let baseResponse = try await remoteDataSource.fetch(request)

      guard baseResponse.isSuccessful else {
        let errorResponse = ErrorResponse(
          status: baseResponse.status,
          message: baseResponse.message,
          code: nil
        )
        return .failure(AboutThePlaceRepositoryError.backend(errorResponse))
      }

      guard let responseDTO = baseResponse.object else {
        return .failure(AboutThePlaceRepositoryError.emptyResponseObject)
      }

      let response = responseDTO.toDomain()

      do {
        try await localDataSource.save(response.entity)
      } catch {
        Log.warning(
          "Failed to cache entity after fetch: \(error.localizedDescription)",
          instance: self
        )
      }

      return .success(response)
    } catch {
      return .failure(AboutThePlaceRepositoryError.network(error))
    }
  }

  /// Persists the given entity by delegating to the remote data source and
  /// optionally updating the local storage.
  ///
  /// - Parameter entity: The entity to be persisted.
  /// - Returns: A result indicating whether the operation succeeded or failed.
  public func persist(
    _ entity: AboutThePlaceEntity
  ) async -> Result<Void, Error> {
    do {
      let dto = AboutThePlaceEntityDTO(entity: entity)
      let baseResponse = try await remoteDataSource.persist(dto)

      guard baseResponse.isSuccessful else {
        let errorResponse = ErrorResponse(
          status: baseResponse.status,
          message: baseResponse.message,
          code: nil
        )
        return .failure(AboutThePlaceRepositoryError.backend(errorResponse))
      }

      do {
        try await localDataSource.save(entity)
      } catch {
        Log.warning(
          "Failed to cache entity after persist: \(error.localizedDescription)",
          instance: self
        )
      }

      return .success(())
    } catch {
      return .failure(AboutThePlaceRepositoryError.network(error))
    }
  }
}
