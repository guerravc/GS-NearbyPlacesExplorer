# Dependency Injection — Style Guide

GS-NearbyPlacesExplorer utilizes a native, lightweight, thread-safe Dependency Injection (DI) system centered around the `DependencyContainer`.

This approach avoids heavy third-party frameworks like Swinject, keeping the app fast and tightly integrated with Swift 6 Concurrency constraints.

## 📦 `DependencyContainer` Overview

The `DependencyContainer` (located in `AppCore/Core/DI/DependencyContainer.swift`) is a thread-safe singleton (`@unchecked Sendable` protected by `OSAllocatedUnfairLock`).

It supports two types of registrations:
1. **Singleton (Instance):** The container holds a single, shared instance for the lifetime of the app.
2. **Factory:** The container executes a closure to return a fresh instance every time the dependency is resolved.

## 📝 Registration

Service registration should occur at the application startup phase (e.g., in `App.swift` or a dedicated `Bootstrap` module) before any UI is rendered.

```swift
// Registering a Singleton (e.g., APIClient)
DependencyContainer.shared.registerSingleton(
    APIClient.self,
    DefaultAPIClient(dispatcher: APIRequestDispatcher())
)

// Registering a Factory (e.g., Use Cases that are stateless structs)
DependencyContainer.shared.registerFactory(GetNearbyPlacesUseCaseProtocol.self) {
    GetNearbyPlacesUseCase(apiClient: DependencyContainer.shared.resolve())
}
```

### Named Dependencies
If you have multiple implementations of the same protocol, you can use the `name` parameter to disambiguate:

```swift
DependencyContainer.shared.registerSingleton(
    AuthTokenProviding.self, 
    name: "google", 
    GoogleAuthTokenProvider()
)
```

## 🔍 Resolution

To retrieve a dependency, use the `resolve()` method. 

> **Important:** `resolve()` uses `fatalError` if a dependency is not found. This is intentional: missing dependencies are developer errors that should be caught immediately during integration. If a dependency is truly optional, use `resolveOptional()`.

### In ViewModels
ViewModels should receive their dependencies via `DependencyContainer.shared.resolve()` during their initialization. They do NOT need to expose init parameters unless they are designed to be mocked explicitly in previews.

```swift
@MainActor
@Observable
final class PlacesListViewModel {
    private let getPlacesUseCase: GetNearbyPlacesUseCaseProtocol
    
    // Resolve directly inside the ViewModel init
    init(getPlacesUseCase: GetNearbyPlacesUseCaseProtocol = DependencyContainer.shared.resolve()) {
        self.getPlacesUseCase = getPlacesUseCase
    }
}
```

### In Use Cases and Gateways
Stateless types (like Use Cases and Repositories) should use standard initializer injection. The `DependencyContainer` resolves these dependencies upstream when registering the factory.

```swift
// Domain Protocol
protocol GetNearbyPlacesUseCaseProtocol {
    func execute() async throws -> [Place]
}

// Concrete Implementation
struct GetNearbyPlacesUseCase: GetNearbyPlacesUseCaseProtocol {
    private let apiClient: APIClient
    
    // Use Case explicitly demands its dependencies via init
    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }
    
    func execute() async throws -> [Place] { ... }
}
```

## 🧪 Testing

Because Use Cases, ViewModels, and Repositories expose their dependencies through their initializers, you do not need to rely on the global `DependencyContainer` in unit tests. You can directly inject Mocks or Stubs into the SUT (System Under Test).

```swift
@Test
func testPlacesListViewModel() async {
    let mockUseCase = MockGetNearbyPlacesUseCase()
    let viewModel = PlacesListViewModel(getPlacesUseCase: mockUseCase)
    
    // Perform assertions...
}
```

### Resetting the Container
If you need to run integration tests that manipulate the shared container, ensure you call `DependencyContainer.shared.reset()` during the test teardown to avoid bleeding state across tests.

---
**See also:**
- [Main Style Guide Index](STYLEGUIDE.md)
