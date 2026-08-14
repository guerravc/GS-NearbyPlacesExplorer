# Architecture — Style Guide

This section covers Clean Architecture, MVVM, and SwiftUI State Management as applied in the GS-NearbyPlacesExplorer project.

## 🏗 Architectural Responsibility Split

This project strictly separates concerns using Clean Architecture for business logic and MVVM for presentation.

### 🧭 Feature-Based Clean Architecture (Vertical Slices)

Rather than having massive, global `Domain` or `Data` folders, Clean Architecture is applied per **Feature** (Vertical Slicing). Every feature module (e.g., `Features/Login`, `Features/NearbyPlaces`) should contain its own isolated layers:

- **`Domain/`**: The core logic specific to this feature. Contains Use Cases, feature-specific Entities, and Repository Protocols. This layer is strictly independent and must **never** import SwiftUI or Combine.
- **`Data/`**: Implements the domain repository protocols for this feature. Contains networking DTOs and API calls specific to the feature.
- **`Presentation/`**: Applies the MVVM pattern for this specific feature:
  - 🖼 **SwiftUI Views**: Render UI and trigger intents based on user interaction. Must be declarative and contain no complex business logic.
  - 🧠 **ViewModels**: Manage UI state (`@Observable`) and handle side effects. They communicate exclusively with the `Domain` layer via Use Cases.

### 🌎 `AppCore/` (Cross-Cutting Concerns)

The `AppCore` directory provides infrastructure and shared domain protocols that transcend a single feature:
- Global Entities or generic base DTOs.
- Infrastructure (like the `DependencyContainer` and `Log.swift`).
- Generic Data providers (if any) shared across features.

### 🗺 Layer Mapping

| Layer | Location | Responsibility | Pattern |
|-------|----------|----------------|---------|
| SwiftUI Views | `Features/<Name>/Presentation` | Rendering, layout, user events | MVVM (View) |
| ViewModels | `Features/<Name>/Presentation` | UI state, orchestration, side effects | MVVM (ViewModel) |
| Use Cases | `Features/<Name>/Domain` | Business rules and application logic | Clean (Domain) |
| Entities | `Features/<Name>/Domain` | Core business models | Clean (Domain) |
| Repositories | `Features/<Name>/Data` | Data access and infrastructure | Clean (Data) |

---

## 📏 Explicit Architecture Rules

### 🧼 Clean Architecture Rules

- **Use Cases** must be stateless and side-effect free (except through injected gateways/repositories).
- Domain code must use Swift 6 `async/await` for concurrency.
- **Boundaries**: Avoid mapping internal optional properties (like network DTO optionality) directly to Domain entities unless the absence of data is a core business requirement.
- **Dependency Inversion**: High-level modules (Domain) must not depend on low-level modules (Data). Both depend on abstractions (Protocols).

### 🧩 MVVM & SwiftUI Rules

- **ViewModels** must use the `@Observable` macro (introduced in iOS 17) rather than the legacy `ObservableObject` / `@Published` stack.
- ViewModels must be marked with `@MainActor` to ensure state mutations always occur on the main thread.
- Views must not mutate ViewModel properties directly; they should call explicit intent methods (e.g., `viewModel.didTapLogin()`).
- Avoid mixing UI state (like `isSheetPresented`) with Domain state in the Use Case. Let the ViewModel orchestrate that.

### 🧱 ViewState Pattern

For complex screens, avoid multiple loose booleans (e.g., `isLoading`, `hasError`). Instead, define a `ViewState` enum in the ViewModel to clearly represent mutually exclusive states:

```swift
@MainActor
@Observable
final class PlacesListViewModel {
    enum ViewState {
        case idle
        case loading
        case loaded([Place])
        case error(String)
    }
    
    private(set) var state: ViewState = .idle
    
    // Dependencies injected via DependencyContainer
    private let getPlacesUseCase: GetNearbyPlacesUseCaseProtocol
    
    // ...
}
```

---

## 🚫 Common Anti-Patterns

- **ViewModels containing business rules:** If the logic determines *what* happens (data transformation, business validation), it belongs in a Use Case.
- **Views depending on Repositories:** Views should only ever interact with ViewModels or localized State objects.
- **Use Cases importing SwiftUI:** A Use Case should be testable purely as a Swift component without any UI framework context.
- **Optional Domain Models:** Passing network optionality into domain layers forcing the UI to handle `nil` checks for core business data. Resolve optionality at the Data layer mapping boundary.

---
**See also:**
- [Main Style Guide Index](STYLEGUIDE.md)
- [Dependency Injection Guide](STYLEGUIDE-DI.md)
