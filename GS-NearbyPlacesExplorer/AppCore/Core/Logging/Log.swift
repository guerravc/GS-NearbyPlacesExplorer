// 
//  Log.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import Foundation
import OSLog
import os

/// A lightweight logging utility for the application.
/// Provides log output categorized by severity levels.
///
/// In DEBUG builds, all log levels are emitted.
/// In RELEASE builds, only warnings and errors are emitted.
public enum Log {

  // MARK: - Logger

  /// Shared OSLog logger instance used by all log outputs.
  ///
  /// - Note: The subsystem uses the main bundle identifier when available,
  ///   so logs can be easily filtered in Console.app.
  private static let logger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "App",
    category: "guerralog"
  )

  // MARK: - Clock

  /// Monotonic clock seed (in uptime nanoseconds) used to compute elapsed times (`t=...ms`).
  private static let clockSeed = OSAllocatedUnfairLock<UInt64>(
    initialState: DispatchTime.now().uptimeNanoseconds
  )

  /// Resets the monotonic clock seed to "now".
  ///
  /// Use this to measure elapsed time from a new logical start point
  /// (e.g., app launch phase, user flow start, etc.).
  public static func resetClock() {
    clockSeed.withLock { seed in
      seed = DispatchTime.now().uptimeNanoseconds
    }
  }

  /// Sets the monotonic clock seed to a specific uptime value.
  ///
  /// - Parameter uptimeNanoseconds: Uptime in nanoseconds (monotonic time base).
  ///
  /// This is useful if you want multiple subsystems to share the same seed.
  public static func setClockSeed(uptimeNanoseconds: UInt64) {
    clockSeed.withLock { seed in
      seed = uptimeNanoseconds
    }
  }

  // MARK: - Public API

  /// Logs a debug-level message. Emitted only in DEBUG builds.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - instance: The instance originating the log. Must be a reference type
  ///     (`AnyObject`) so `Unmanaged.passUnretained` can derive the pointer
  ///     address used as `selfId` — enabling cross-thread identity tracking
  ///     without requiring `Hashable` or `Identifiable`. (ADR-002)
  ///   - file: The file name where the log originates.
  ///   - function: The function name where the log originates.
  ///   - line: The line number where the log originates.
  public static func debug(
    _ message: String,
    instance: AnyObject,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    #if DEBUG
    let formatted = format(
      level: "🐛 DEBUG",
      message: message,
      instance: instance,
      file: file,
      function: function,
      line: line
    )
    logger.debug("\(formatted, privacy: .public)")
    #endif
  }

  /// Logs an informational message.
  /// Emitted in DEBUG builds. Suppressed in RELEASE builds.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - instance: The instance originating the log. Used to print `selfId`.
  ///   - file: The file name where the log originates.
  ///   - function: The function name where the log originates.
  ///   - line: The line number where the log originates.
  public static func info(
    _ message: String,
    instance: AnyObject,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    #if DEBUG
    let formatted = format(
      level: "ℹ️ INFO",
      message: message,
      instance: instance,
      file: file,
      function: function,
      line: line
    )
    logger.info("\(formatted, privacy: .public)")
    #endif
  }

  /// Logs a warning message.
  /// Emitted in all build configurations.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - instance: The instance originating the log. Used to print `selfId`.
  ///   - file: The file name where the log originates.
  ///   - function: The function name where the log originates.
  ///   - line: The line number where the log originates.
  ///
  /// - ADR-001: OSLog does not expose a `warning` level. `Logger.notice` is
  ///   the closest semantic equivalent and is persisted by default, making it
  ///   visible in Console.app without enabling debug-level logging.
  public static func warning(
    _ message: String,
    instance: AnyObject,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    let formatted = format(
      level: "⚠️ WARNING",
      message: message,
      instance: instance,
      file: file,
      function: function,
      line: line
    )
    logger.notice("\(formatted, privacy: .public)")
  }

  /// Logs an error message.
  /// Always emitted regardless of build configuration.
  ///
  /// - Parameters:
  ///   - message: The message to log.
  ///   - instance: The instance originating the log. Used to print `selfId`.
  ///   - file: The file name where the log originates.
  ///   - function: The function name where the log originates.
  ///   - line: The line number where the log originates.
  public static func error(
    _ message: String,
    instance: AnyObject,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) {
    let formatted = format(
      level: "❌ ERROR",
      message: message,
      instance: instance,
      file: file,
      function: function,
      line: line
    )
    logger.error("\(formatted, privacy: .public)")
  }

  // MARK: - Formatting

  /// Builds the formatted log message.
  ///
  /// Final format:
  /// `[LEVEL] [File Function:Line] [selfId=0x123] [thread=main|bg] [t=34ms] - message`
  ///
  /// - Parameters:
  ///   - level: The human-readable log level tag.
  ///   - message: The message to log.
  ///   - instance: The instance originating the log.
  ///   - file: The file name where the log originates.
  ///   - function: The function name where the log originates.
  ///   - line: The line number where the log originates.
  ///
  /// - Returns: A formatted log line ready for OSLog emission.
  private static func format(
    level: String,
    message: String,
    instance: AnyObject,
    file: String,
    function: String,
    line: Int
  ) -> String {
    let fileName = (file as NSString).lastPathComponent
      .components(separatedBy: ".")
      .first ?? "UnknownFile"

    let thread = Thread.isMainThread ? "main" : "bg"
    let elapsed = elapsedMilliseconds()
    let selfId = hexObjectId(instance)

    return "[\(level)] [\(fileName) \(function):\(line)] [selfId=\(selfId)] [thread=\(thread)] [t=\(elapsed)ms] - \(message)"
  }

  /// Computes elapsed milliseconds since the current clock seed.
  ///
  /// - Returns: Milliseconds elapsed from the stored monotonic seed.
  private static func elapsedMilliseconds() -> UInt64 {
    let now = DispatchTime.now().uptimeNanoseconds
    let seed = clockSeed.withLock { $0 }
    return (now &- seed) / 1_000_000
  }

  /// Builds a hexadecimal identifier for an object instance.
  ///
  /// - Parameter instance: The instance to identify.
  /// - Returns: A `0x...` hex string derived from the object's pointer.
  private static func hexObjectId(_ instance: AnyObject) -> String {
    let ptr = Unmanaged.passUnretained(instance).toOpaque()
    let value = UInt(bitPattern: ptr)
    return "0x" + String(value, radix: 16)
  }
}