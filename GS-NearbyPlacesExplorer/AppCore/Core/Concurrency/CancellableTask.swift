// 
//  CancellableTask.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation

/// A property wrapper that manages a single cancellable `Task`.
///
/// When a new task is assigned, the previous one is automatically cancelled.
/// When the owning type is deallocated, the last task is also cancelled.
///
/// Designed primarily for `@MainActor` types such as SwiftUI view models.
/// It is not thread-safe for mutation from multiple actors.
///
/// Usage:
///
/// ```swift
/// @CancellableTask<Void, Never> private var searchTask
///
/// func search(text: String) {
///     searchTask = Task {
///         // Do async work here
///     }
/// }
/// ```
///
/// The previous task is cancelled automatically when a new task is set.
@propertyWrapper
public struct CancellableTask<Success, Failure> where Failure: Error {

    /// Internal storage that cancels the previous task whenever a new one
    /// is assigned, and also cancels on deallocation.
    private final class Storage {
        var task: Task<Success, Failure>? {
            didSet {
                oldValue?.cancel()
            }
        }

        deinit {
            task?.cancel()
        }
    }

    private let storage = Storage()

    /// Creates an empty cancellable task wrapper.
    public init() { }

    /// The current task.
    /// Assigning a new task cancels the previous one automatically.
    public var wrappedValue: Task<Success, Failure>? {
        get { storage.task }
        set { storage.task = newValue }
    }

    /// The projected value exposes the wrapper itself, allowing explicit
    /// cancellation:
    ///
    /// ```swift
    /// $task.cancel()
    /// ```
    public var projectedValue: CancellableTask<Success, Failure> {
        self
    }

    /// Cancels the current task, if any.
    public func cancel() {
        storage.task?.cancel()
    }
}