# Logging — Style Guide

This guide details the custom, lightweight logging utility (`Log.swift`) used in `GS-NearbyPlacesExplorer`.

## 🪵 Overview

The application relies on a unified `Log` enum (`AppCore/Core/Logging/Log.swift`) which serves as a wrapper over Apple's native `OSLog` (`os.Logger`).

By routing all console outputs through `Log.swift`, we achieve:
1. **Consistency:** All logs follow a strict format.
2. **Filtering:** Easy filtering in macOS Console.app using the `guerralog` category.
3. **Safety:** Logs are stripped of unnecessary debug noise in Release builds.
4. **Correlation:** Instances are tracked via their pointer addresses (`selfId`) to debug memory leaks.
5. **Temporal Context:** Every log prints the elapsed milliseconds (`t=...ms`) since a shared clock seed.

## 🚦 Choosing a Log Level

You must pick the appropriate log level based on the severity and purpose of the message.

| Level | Method | When to use |
|-------|--------|-------------|
| **Debug** | `Log.debug` | Verbose diagnostic traces useful during development. Emitted **only** in DEBUG builds. |
| **Info** | `Log.info` | Normal expected flow events (e.g., "Screen loaded", "Request started"). Emitted **only** in DEBUG builds. |
| **Warning**| `Log.warning` | Recoverable anomalies, unexpected API formats, or deprecations. Emitted in ALL builds. Maps to `OSLogType.notice`. |
| **Error** | `Log.error` | Hard failures affecting functionality (e.g., decoding errors, network timeouts). Emitted in ALL builds. |

## 🔗 The `instance: self` Rule

Almost all `Log` methods require an `instance: AnyObject` parameter. This is used to derive a `selfId` (e.g., `0x10a2b4c00`), allowing developers to visually correlate all logs originating from the exact same object in memory.

**Rule:** Always pass `instance: self` when logging from a `class` or `actor`.

```swift
@MainActor
final class LoginViewModel {
    init() {
        Log.info("LoginViewModel initialized", instance: self)
    }
    
    deinit {
        Log.info("LoginViewModel deallocated", instance: self)
    }
    
    func performLogin() {
        Log.debug("Login flow started", instance: self)
    }
}
```

> **Note on Structs:** If you need to log from a value type (`struct` or `enum`), do not wrap it in `AnyObject` manually as the address will be meaningless. (Currently, the utility is optimized for reference types; if you must log from a struct, you might need to adapt `Log.swift` to accept an optional instance or provide a static identifier).

## ⏱ Temporal Clock (`resetClock`)

The log automatically prepends an elapsed time marker `[t=150ms]` relative to a monotonic clock seed.

**When to call `Log.resetClock()`:**
- Always call it at the application launch (e.g., `App.init`).
- Optionally call it at the exact start of a critical flow (like starting a Checkout or Login flow) to measure the relative time it takes for subsequent steps to execute.

## 🚫 Anti-Patterns

- **Never use `print()` or `NSLog()`** in production code. Always use `Log.debug/info/warning/error`.
- **Do not leak PII (Personally Identifiable Information).** Ensure that you do not log passwords, tokens, or sensitive user data. `OSLog` defaults to `.public` privacy inside our utility to aid debugging, meaning any string you pass will be visible in the system console.

---
**See also:**
- [Main Style Guide Index](STYLEGUIDE.md)
