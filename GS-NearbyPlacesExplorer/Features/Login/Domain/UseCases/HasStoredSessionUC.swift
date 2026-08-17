// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation

/// Async query Use Case for determining whether a local session can be restored.
public protocol HasStoredSessionUC: AsyncQueryUseCase where Output == Bool { }

/// Default implementation of ``HasStoredSessionUC``.
public final class HasStoredSessionUCImpl: HasStoredSessionUC {
  @Inject var gateway: LoginGateway

  public init() {}

  public func execute() async -> Result<Bool, Error> {
    .success(gateway.hasStoredSession())
  }
}
