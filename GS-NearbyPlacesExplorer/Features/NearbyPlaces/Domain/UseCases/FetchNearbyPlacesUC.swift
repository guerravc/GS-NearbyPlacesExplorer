// 
//  FetchNearbyPlacesUC.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation

/// Async operation Use Case for fetching data of the NearbyPlaces module.
///
/// This use case demonstrates how to interact with the gateway layer using the
/// base use case protocol `AsyncOperationUseCase`.
///
/// The output type is the domain entity, so presentation layers can work directly
/// with a clean model and map it to their own view models if needed.
public protocol FetchNearbyPlacesUC: AsyncOperationUseCase
where Output == NearbyPlacesEntity { }

/// Default implementation of `FetchNearbyPlacesUC`.
///
/// This type coordinates the module gateway and exposes a single async `execute`
/// entry point that returns a `Result` with the domain entity or an error.
public struct FetchNearbyPlacesUCImpl: FetchNearbyPlacesUC {
  
  // MARK: - Input
  
  /// Input required by the use case.
  /// In this case, a request model with parameters required by the backend.
  public struct Input: Sendable {
    /// Request model used to configure the backend operation.
    public let request: NearbyPlacesRequest
    
    /// Creates a new input instance.
    /// - Parameter request: Request model with the parameters needed by the backend.
    public init(request: NearbyPlacesRequest) {
      self.request = request
    }
  }
  
  // MARK: - Dependencies
  
  /// Gateway responsible for fetching the module's data.
  private let gateway: NearbyPlacesGateway
  
  /// Creates a new instance of the use case implementation.
  /// - Parameter gateway: Gateway used to perform the data-fetching operation.
  public init(gateway: NearbyPlacesGateway) {
    self.gateway = gateway
  }
  
  // MARK: - Execute
  
  /// Executes the use case asynchronously.
  ///
  /// - Parameter input: Required parameters to perform the operation.
  /// - Returns: A `Result` containing the domain entity or an error.
  public func execute(
    _ input: Input
  ) async -> Result<Output, Error> {
    let result = await gateway.fetch(input.request)
    
    switch result {
    case .success(let response):
      // Map the response wrapper to the pure domain entity.
      return .success(response.entity)
    case .failure(let error):
      return .failure(error)
    }
  }
}