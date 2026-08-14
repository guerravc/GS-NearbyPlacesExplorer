# Code Style — Style Guide

This section covers Clean Code principles, Swift style conventions, and Swift 6 Strict Concurrency compliance for GS-NearbyPlacesExplorer.

## 🧭 Principles

- 👓 **Readability over cleverness**: Write code that is easy to understand.
- 🧩 **Single responsibility**: Classes, structs, and functions should do one thing well.
- 🧱 **Small, focused changes**: Keep PRs tight and scoped.
- 🤖 **Predictable patterns for AI tools**: Consistent architecture helps code-gen and AI assistants work flawlessly.

## 🏷 Meaningful Names

- 🗣 Use expressive, intention-revealing names.
- 🔠 **Casing:**
  - `camelCase` for variables and functions (e.g., `fetchPlaces`, `currentUser`).
  - `PascalCase` for types (structs, classes, protocols, e.g., `NearbyPlacesViewModel`).
  - `lowerCamelCase` for enum cases (e.g., `.loading`, `.success`).
- ✅ **Booleans** use `is`/`has`/`can`/`should` prefixes (e.g., `isLoading`, `hasLocationPermission`).
- 📁 **Files** should have the same name as the primary type they contain (e.g., `DependencyContainer.swift`).

## 🧮 Functions & Methods

- 🧩 Keep functions small and single-purpose.
- ✂ If a function needs explanation, split it and give subfunctions meaningful names.
- 🚀 Use verbs for actions (`loadPlaces()`, `selectFavorite()`).
- 📦 Group parameters; if a method has >3 parameters, consider creating a small `Input` struct.

## 📐 Formatting & Layout

- 📏 **Line length:** Soft limit at 100 characters, strict limit at 120.
- 🧻 Use whitespace to separate logical blocks within functions.
- 📁 One top-level type per file.
- 📘 Use `///` for public APIs or complex methods to enable Xcode Quick Help. Avoid redundant comments that just restate the code. Explain *why*, not *what*.

## 📱 SwiftUI Rules

- ✂ Keep `body` concise. Extract repeated or complex subtrees into small private `View` types or computed properties.
- 🎯 Views call intent methods on ViewModels (e.g., `viewModel.onAppear()`). Do not embed business logic in button closures.
- 🎞 Use `withAnimation` explicitly when state changes should trigger visual transitions.

## 🚀 Swift 6 Strict Concurrency

This project compiles under Swift 6 language mode with Strict Concurrency enabled.

### `@Sendable` and Explicit Captures

`Task {}`, `group.addTask {}`, and `AsyncStream` continuations require explicit capture of properties under Swift 6. The compiler will reject implicit captures of `self` to enforce thread safety.

```swift
// ✅ Explicit local capture
func loadData() {
    let useCase = self.getPlacesUseCase
    Task {
        let places = try await useCase.execute()
    }
}

// ❌ Implicit self capture rejected by Swift 6
func loadData() {
    Task {
        let places = try await self.getPlacesUseCase.execute()
    }
}
```

### Struct vs Class for Stateless Components

Prefer `struct` for stateless components (Use Cases, Network Dispatchers, Adapters). Because structs are value types, they natively satisfy `Sendable` if their properties are `Sendable`. 

Use `class` (or `final class`) only when:
- The component requires **identity semantics** or lifecycle callbacks (e.g., `deinit`).
- The component holds **shared mutable observable state** consumed by SwiftUI (e.g., `@Observable final class`).
- You are using `OSAllocatedUnfairLock` or other explicit synchronization mechanisms internally and must mark the class as `@unchecked Sendable` (do this sparingly and intentionally, e.g., `DependencyContainer`).

### Main Actor Isolation

Always apply `@MainActor` to ViewModels and UI-State holders. If a specific background operation is needed, detach it via `Task { ... }` or move it to the Domain/Data layer, ensuring UI state updates return to the Main Actor.

---
**See also:**
- [Main Style Guide Index](STYLEGUIDE.md)
- [Architecture Guide](STYLEGUIDE-ARCHITECTURE.md)
