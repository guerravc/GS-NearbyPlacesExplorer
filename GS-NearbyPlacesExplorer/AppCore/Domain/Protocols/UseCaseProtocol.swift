// 
//  UseCaseProtocol.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

// MARK: - Synchronous (closure-based) use cases

/// Represents a use case that performs an action without input or output.
/// This is typically used for fire-and-forget style operations.
public protocol ActionUseCase {
  /// Executes the use case.
  func execute()
}

/// Represents a use case that retrieves data without requiring input
/// and delivers the result asynchronously using a completion handler.
public protocol QueryUseCase {
  /// The type of the value produced by the use case.
  associatedtype Output

  /// Executes the use case and delivers the result in the completion handler.
  /// - Parameter completion: Closure that receives the operation result.
  func execute(completion: @escaping (Result<Output, Error>) -> Void)
}

/// Represents a use case that performs a command with input and reports only
/// success or failure asynchronously using a completion handler.
public protocol CommandUseCase {
  /// The type of the input required by the use case.
  associatedtype Input

  /// Executes the use case with the given input and delivers a `Result`
  /// indicating whether the operation succeeded or failed.
  /// - Parameters:
  ///   - input: The input required to perform the operation.
  ///   - completion: Closure that receives the operation result.
  func execute(
    _ input: Input,
    completion: @escaping (Result<Void, Error>) -> Void
  )
}

/// Represents a use case that transforms an input into an output and delivers
/// the result asynchronously using a completion handler.
public protocol OperationUseCase {
  /// The type of the input required by the use case.
  associatedtype Input
  /// The type of the value produced by the use case.
  associatedtype Output

  /// Executes the use case with the given input and delivers the result
  /// in the completion handler.
  /// - Parameters:
  ///   - input: The input required to perform the operation.
  ///   - completion: Closure that receives the operation result.
  func execute(
    _ input: Input,
    completion: @escaping (Result<Output, Error>) -> Void
  )
}

// MARK: - Asynchronous (Swift Concurrency) use cases

/// Represents an asynchronous use case without input that reports only
/// success or failure.
/// The result is returned as `Result<Void, Error>`.
public protocol AsyncActionUseCase {
  /// Executes the use case asynchronously.
  /// - Returns: A result indicating whether the operation succeeded or failed.
  func execute() async -> Result<Void, Error>
}

/// Represents an asynchronous use case without input that produces a value
/// or an error using Swift concurrency.
public protocol AsyncQueryUseCase {
  /// The type of the value produced by the use case.
  associatedtype Output

  /// Executes the use case asynchronously.
  /// - Returns: A result containing the output value or an error.
  func execute() async -> Result<Output, Error>
}

/// Represents an asynchronous use case that performs a command with input
/// and reports only success or failure using Swift concurrency.
public protocol AsyncCommandUseCase {
  /// The type of the input required by the use case.
  associatedtype Input

  /// Executes the use case asynchronously with the given input.
  /// - Parameter input: The input required to perform the operation.
  /// - Returns: A result indicating whether the operation succeeded or failed.
  func execute(_ input: Input) async -> Result<Void, Error>
}

/// Represents an asynchronous use case that transforms an input into an output
/// and reports the result using Swift concurrency.
public protocol AsyncOperationUseCase {
  /// The type of the input required by the use case.
  associatedtype Input
  /// The type of the value produced by the use case.
  associatedtype Output

  /// Executes the use case asynchronously with the given input.
  /// - Parameter input: The input required to perform the operation.
  /// - Returns: A result containing the output value or an error.
  func execute(_ input: Input) async -> Result<Output, Error>
}