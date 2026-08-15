---
name: "Google Login Feature"
overview: "Implement Google SignIn with Clean Architecture, Keychain storage, Router navigation, and a 2s transitory SwiftUI view."
isProject: false
todos:
  - id: 1
    content: "Add Google SignIn SDK & Implement KeychainRepository"
    status: pending
  - id: 2
    content: "Implement AuthUseCase for Google SignIn logic"
    status: pending
  - id: 3
    content: "Implement AppRouter (Navigation state)"
    status: pending
  - id: 4
    content: "Implement LoginViewModel (State, 2s timer calling Router)"
    status: pending
  - id: 5
    content: "Implement LoginView & LoginTransitoryView UI"
    status: pending
---

## Increments

### Increment 1: Add Google SignIn SDK & Implement KeychainRepository
- **Goal:** Establish secure persistence (`INV-001`) and SPM dependency.
- **Steps:**
  1. Add `GoogleSignIn` via SPM in the Xcode project configuration.
  2. Implement `KeychainRepository` (and protocol) for token storage.
  3. Verify reading/writing securely.
- **Files modified:** `GS-NearbyPlacesExplorer.xcodeproj/project.pbxproj`
- **Files created:** `GS-NearbyPlacesExplorer/Features/Login/Data/Repositories/KeychainRepository.swift`
- **Tests affected:** `None — no existing tests modified`
- **Tests created:** `GS-NearbyPlacesExplorerTests/Features/Login/Data/KeychainRepositoryTests.swift`

### Increment 2: Implement AuthUseCase
- **Goal:** Abstract Google SDK logic away from Presentation (`BND-001`), handling cancellations (`FAIL-002`).
- **Steps:**
  1. Create `AuthUseCaseProtocol` and `AuthUseCaseImpl`.
  2. Integrate GoogleSignIn sign-in logic mapping it to a Domain entity.
  3. Handle SDK errors (distinguishing user cancellation from network failures).
- **Files modified:** `None — increment only creates new files`
- **Files created:** `GS-NearbyPlacesExplorer/Features/Login/Domain/UseCases/AuthUseCase.swift`
- **Tests affected:** `None — no existing tests modified`
- **Tests created:** `GS-NearbyPlacesExplorerTests/Features/Login/Domain/AuthUseCaseTests.swift`

### Increment 3: Implement AppRouter
- **Goal:** Provide central routing using `NavigationPath` (`OWN-001`).
- **Steps:**
  1. Create `@Observable final class AppRouter` containing a `NavigationPath`.
  2. Define a `Destination` enum (e.g., `nearbyPlaces`).
  3. Inject it into the App environment and wrap the main view in `NavigationStack(path: $router.path)`.
- **Files modified:** `GS-NearbyPlacesExplorer/AppCore/App/GS_NearbyPlacesExplorerApp.swift`
- **Files created:** `GS-NearbyPlacesExplorer/AppCore/Navigation/AppRouter.swift`
- **Tests affected:** `None — no existing tests modified`
- **Tests created:** `None — router UI testing deferred`

### Increment 4: Implement LoginViewModel
- **Goal:** Provide presentation state, handle timing (`INV-002`), map network errors (`FAIL-001`), and trigger navigation.
- **Steps:**
  1. Define View states (Idle, Success(Profile), Error(Message)) and an `isLoading` boolean flag to control the button's spinner and disabled state.
  2. Inject `AuthUseCase` and `AppRouter`.
  3. On success, trigger a 2-second `Task.sleep`, then call `router.path.append(.nearbyPlaces)`.
  4. On failure, emit the exact string "Error de red. Inténtalo de nuevo."
- **Files modified:** `None — increment only creates new files`
- **Files created:** `GS-NearbyPlacesExplorer/Features/Login/Presentation/ViewModels/LoginViewModel.swift`
- **Tests affected:** `None — no existing tests modified`
- **Tests created:** `GS-NearbyPlacesExplorerTests/Features/Login/Presentation/LoginViewModelTests.swift`

### Increment 5: Implement LoginView & LoginTransitoryView UI
- **Goal:** Build the SwiftUI interface matching the reference design and implement the transitory view.
- **Steps:**
  1. Create `LoginView` with texts, colors, and SF Symbols per the `specs.design.md`.
  2. Create `LoginTransitoryView` for the 2-second success state.
  3. Bind the Google button to the `isLoading` flag: when true, disable the button and show a `ProgressView` inside it. Resets to false on success, error, or cancellation.
  3. Implement `.alert` for network errors.
  4. Apply `.transition(.opacity.animation(.easeInOut))` for the state swap.
- **Files modified:** `None — increment only creates new files`
- **Files created:** 
  - `GS-NearbyPlacesExplorer/Features/Login/Presentation/Views/LoginView.swift`
  - `GS-NearbyPlacesExplorer/Features/Login/Presentation/Views/LoginTransitoryView.swift`
- **Tests affected:** `None — UI manual verification`
- **Tests created:** `None — UI testing deferred`

## Improvement Margin
- None

## Self Code Review
- Does the Keychain wrapper avoid storing values in UserDefaults?
- Are errors accurately mapped so that ONLY network failures trigger the alert?
- Does the 2-second delay block the main thread? (Must use `Task.sleep` without blocking).
- Is `GoogleSignIn` imported ONLY in the Data/Domain layer and NOT in the `LoginViewModel` or `LoginView`?
- Is the router properly modifying `NavigationPath` on the main thread?

## Testing
- **Security (`INV-001`):** Mock Keychain interactions in unit tests to ensure credentials aren't passed to print statements or insecure storage.
- **Timing (`INV-002`):** Use a controllable clock or async test expectations in `LoginViewModelTests` to verify the 2-second delay and subsequent router call.
- **Architecture (`BND-001`):** Ensure the Presentation layer does not rely on any `GIDGoogleUser` object, only domain entities.
- **Error paths (`FAIL-001`, `FAIL-002`):** `LoginViewModelTests` must assert that cancellation yields `state == .idle` and network error yields `state == .error("Error de red. Inténtalo de nuevo.")`.

## Governance
- **Approval Gate:** Required after Increment 1 to verify Keychain logic before proceeding with the UseCase.
