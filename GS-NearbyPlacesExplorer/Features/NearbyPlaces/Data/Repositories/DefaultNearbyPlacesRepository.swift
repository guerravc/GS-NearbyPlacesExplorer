// 
//  DefaultNearbyPlacesRepository.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Default repository implementation for the NearbyPlaces module.
///
/// This type implements the domain `NearbyPlacesGateway` protocol and
/// coordinates the remote service and local storage layers. It is responsible for:
/// - Calling the remote data source (service) and interpreting `BaseResponse`
///   envelopes returned by the backend.
/// - Mapping DTOs to domain entities.
/// - Optionally caching entities in the local storage.
/// - Mapping infrastructure errors (network, backend) into domain-friendly errors.
public enum NearbyPlacesRepositoryError: Error, @unchecked Sendable {
  /// Represents an error payload returned by the backend.
  case backend(ErrorResponse)
  /// Represents a networking or low-level error.
  case network(Error)
  /// Indicates that the backend response did not contain the expected object.
  case emptyResponseObject
}

/// Default implementation of the module gateway, backed by a remote service
/// and an optional local storage.
public final class DefaultNearbyPlacesRepository: NearbyPlacesGateway {

  // MARK: - Dependencies

  private let remoteDataSource: NearbyPlacesRemoteDataSource
  private let localDataSource: NearbyPlacesLocalDataSource

  // MARK: - Init

  /// Creates a new repository instance.
  ///
  /// - Parameters:
  ///   - remoteDataSource: Remote data source used to perform backend requests.
  ///   - localDataSource: Local data source used to cache or retrieve entities.
  public init(
    remoteDataSource: NearbyPlacesRemoteDataSource,
    localDataSource: NearbyPlacesLocalDataSource
  ) {
    self.remoteDataSource = remoteDataSource
    self.localDataSource = localDataSource
  }

  // MARK: - NearbyPlacesGateway

  /// Fetches data for the given request by delegating to the remote data source
  /// and interpreting the backend `BaseResponse` envelope.
  ///
  /// - Parameter request: Request model to be sent to the backend.
  /// - Returns: A result containing the module response or an error.
  public func fetch(
    _ request: NearbyPlacesRequest
  ) async -> Result<NearbyPlacesResponse, Error> {
    do {
      let baseResponse = try await remoteDataSource.fetch(request)

      guard baseResponse.isSuccessful else {
        let errorResponse = ErrorResponse(
          status: baseResponse.status,
          message: baseResponse.message,
          code: nil
        )
        return .failure(NearbyPlacesRepositoryError.backend(errorResponse))
      }

      guard let responseDTO = baseResponse.object else {
        return .failure(NearbyPlacesRepositoryError.emptyResponseObject)
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
      return .failure(NearbyPlacesRepositoryError.network(error))
    }
  }

  /// Persists the given entity by delegating to the remote data source and
  /// optionally updating the local storage.
  ///
  /// - Parameter entity: The entity to be persisted.
  /// - Returns: A result indicating whether the operation succeeded or failed.
  public func persist(
    _ entity: NearbyPlacesEntity
  ) async -> Result<Void, Error> {
    do {
      let dto = NearbyPlacesEntityDTO(entity: entity)
      let baseResponse = try await remoteDataSource.persist(dto)

      guard baseResponse.isSuccessful else {
        let errorResponse = ErrorResponse(
          status: baseResponse.status,
          message: baseResponse.message,
          code: nil
        )
        return .failure(NearbyPlacesRepositoryError.backend(errorResponse))
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
      return .failure(NearbyPlacesRepositoryError.network(error))
    }
  }
}
