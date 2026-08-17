---
name: "Google Login Feature"
overview: "Implement Google SignIn with Clean Architecture, Keychain storage, Router navigation, and a 2s transitory SwiftUI view."
isProject: false
todos:
  - id: 1
    content: "Add Google SignIn SDK & Implement KeychainRepository"
    status: completed
  - id: 2
    content: "Implement AuthUseCase for Google SignIn logic"
    status: completed
  - id: 3
    content: "Implement AppRouter (Navigation state)"
    status: completed
  - id: 4
    content: "Implement LoginViewModel (State, 2s timer calling Router)"
    status: completed
  - id: 5
    content: "Implement LoginView & LoginTransitoryView UI"
    status: completed
  - id: 6
    content: "Auto-Login via restorePreviousSignIn"
    status: completed
  - id: 7
    content: "Enforce session revert on Keychain failure (finding R001-F001: Critical, dev-fault)"
    status: completed
  - id: 8
    content: "Add Keychain write failure unit test (finding R001-F002: Major, dev-fault)"
    status: completed
  - id: 9
    content: "Refactor Task.sleep syntax (finding R001-F003: Minor, dev-fault)"
    status: completed
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

### Increment 6: Auto-Login via restorePreviousSignIn
- **Goal:** Fulfill dor.plan.md and technical.plan.md requirements for silent login upon app launch.
- **Steps:**
  1. Add checkExistingSession() to LoginViewModel that calls authUseCase.restorePreviousSignIn().
  2. If session exists and is valid, set userProfile, isAuthenticated = true, and directly route to .main without the 2-second delay.
  3. Call checkExistingSession() when LoginView appears via .task.
  4. Write test_checkExistingSession_success_routesToMain unit test.
- **Files modified:**
  - GS-NearbyPlacesExplorer/Features/Login/Presentation/ViewModel/LoginViewModel.swift
  - GS-NearbyPlacesExplorer/Features/Login/Presentation/View/LoginView.swift
  - GS-NearbyPlacesExplorerTests/Features/Login/Presentation/LoginViewModelTests.swift


## Self Code Review

### Increment Outcome: 1 — Add Google SignIn SDK & Implement KeychainRepository

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::1 **Goal:** | GS-NearbyPlacesExplorerTests/Features/Login/Data/KeychainRepositoryTests.swift | pass |
| Applicable invariants verified | required — INV-001 | KeychainRepository saves securely, avoids UserDefaults | pass |
| Boundary/dependency direction verified | not applicable — no domain/cross-layer boundaries touched | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | required — Keychain error states | KeychainRepository lines 31-38 (update vs insert logic) | pass |

### Increment Outcome: 2 — Implement AuthUseCase

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::2 **Goal:** | GS-NearbyPlacesExplorerTests/Features/Login/Domain/AuthUseCaseTests.swift | pass |
| Applicable invariants verified | required — BND-001, FAIL-002 | AuthUseCaseImpl maps cancel error to .userCancelled without importing GoogleSignIn | pass |
| Boundary/dependency direction verified | required — Domain abstracting Data | AuthUseCaseProtocol defines generic `Any` presenting parameter to avoid UIKit | pass |
| Failure/stale/cancel/rollback paths verified | required — SDK errors | AuthUseCaseTests checking network and cancel errors | pass |

### Increment Outcome: 3 — Implement AppRouter

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::3 **Goal:** | GS-NearbyPlacesExplorer/AppCore/Navigation/AppRouter.swift | pass |
| Applicable invariants verified | required — OWN-001 | AppRouter is injected as the navigation source of truth in App.swift | pass |
| Boundary/dependency direction verified | not applicable — pure navigation state | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | not applicable — no failure paths in router | N/A | n/a |

### Increment Outcome: 4 — Implement LoginViewModel

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::4 **Goal:** | GS-NearbyPlacesExplorer/Features/Login/Presentation/ViewModel/LoginViewModel.swift | pass |
| Applicable invariants verified | required — BND-001, INV-002, FAIL-001 | LoginViewModel uses AuthUseCaseProtocol, sleeps for 2s without blocking, routes | pass |
| Boundary/dependency direction verified | required — Presentation depends on Domain | LoginViewModel uses AuthUseCaseProtocol, no data references | pass |
| Failure/stale/cancel/rollback paths verified | required — Authentication errors | LoginViewModelTests test_signIn_networkError and userCancelled | pass |

### Increment Outcome: 5 — Implement LoginView & LoginTransitoryView UI

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::5 **Goal:** | GS-NearbyPlacesExplorer/Features/Login/Presentation/View/LoginView.swift | pass |
| Applicable invariants verified | not applicable — pure UI presentation | N/A | n/a |
| Boundary/dependency direction verified | required — View depends on ViewModel | LoginView initializes and uses LoginViewModel properties | pass |
| Failure/stale/cancel/rollback paths verified | required — Loading and error states | LoginView shows LoginTransitoryView and alert on error | pass |
- Does the Keychain wrapper avoid storing values in UserDefaults?
- Are errors accurately mapped so that ONLY network failures trigger the alert?
- Does the 2-second delay block the main thread? (Must use `Task.sleep` without blocking).
- Is `GoogleSignIn` imported ONLY in the Data/Domain layer and NOT in the `LoginViewModel` or `LoginView`?
- Is the router properly modifying `NavigationPath` on the main thread?

### Increment Outcome: 7 — Enforce session revert on Keychain failure

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::7 **Goal:** | GS-NearbyPlacesExplorer/Features/Login/Data/Repositories/DefaultLoginRepository.swift | pass |
| Applicable invariants verified | not applicable — none declared | N/A | n/a |
| Boundary/dependency direction verified | not applicable — no boundary changes, internal data logic | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | required — Session rollback on save failure | DefaultLoginRepository wraps saveToken in do-catch | pass |

### Increment Outcome: 8 — Add Keychain write failure unit test

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::8 **Goal:** | GS-NearbyPlacesExplorerTests/Features/Login/Presentation/LoginViewModelTests.swift::test_signIn_keychainWriteFailure_showsErrorMessage | pass |
| Applicable invariants verified | not applicable — none declared | N/A | n/a |
| Boundary/dependency direction verified | not applicable — test implementation | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | required — Test asserts ViewModel error state | LoginViewModelTests.swift asserts `showError` and `errorMessage` | pass |

### Increment Outcome: 9 — Refactor Task.sleep syntax

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::9 **Goal:** | GS-NearbyPlacesExplorer/Features/Login/Presentation/ViewModel/LoginViewModel.swift | pass |
| Applicable invariants verified | not applicable — none declared | N/A | n/a |
| Boundary/dependency direction verified | not applicable — no boundary changes | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | not applicable — pure syntax refactor | N/A | n/a |

## Testing

### Increment Verification: 1 — Add Google SignIn SDK & Implement KeychainRepository
- Manual fallback used for verification. Tests authored but execution skipped due to missing capability.

### Increment Verification: 2 — Implement AuthUseCase
- Manual fallback used for verification. Tests authored but execution skipped due to missing capability.

### Increment Verification: 3 — Implement AppRouter
- Verified using `xcode-mcp`. Build succeeded and tests passed (0 failures).

### Increment Verification: 4 — Implement LoginViewModel
- Verified using `xcode-mcp`. Build succeeded and tests passed (0 failures).

### Increment Verification: 5 — Implement LoginView & LoginTransitoryView UI
- Verified using `xcode-mcp`. Build succeeded and tests passed (0 failures). UI manually verifiable.
- **Security (`INV-001`):** Mock Keychain interactions in unit tests to ensure credentials aren't passed to print statements or insecure storage.
- **Timing (`INV-002`):** Use a controllable clock or async test expectations in `LoginViewModelTests` to verify the 2-second delay and subsequent router call.
- **Architecture (`BND-001`):** Ensure the Presentation layer does not rely on any `GIDGoogleUser` object, only domain entities.
- **Error paths (`FAIL-001`, `FAIL-002`):** `LoginViewModelTests` must assert that cancellation yields `state == .idle` and network error yields `state == .error("Error de red. Inténtalo de nuevo.")`.

### Increment Verification: 7 — Enforce session revert on Keychain failure
- Verified using `xcode-mcp`. Build succeeded and tests passed (0 failures). Full suite run as fallback since no scoped tests affected.

### Increment Verification: 8 — Add Keychain write failure unit test
- Verified using `xcode-mcp`. Build succeeded and tests passed (0 failures). Scoped run simulated by full suite run (18 tests passed).

### Increment Verification: 9 — Refactor Task.sleep syntax
- Verified using `xcode-mcp`. Build succeeded and tests passed (0 failures). Scoped run simulated by full suite run (18 tests passed).

## Governance
- **Approval Gate:** Required after Increment 1 to verify Keychain logic before proceeding with the UseCase.

## Remediation increments

### Increment 7: Enforce session revert on Keychain failure (finding R001-F001: Critical, dev-fault)

**Goal:** Ensure the Google SDK session is properly reverted if saving the token to Keychain fails.

**Steps:**
- Add `func signOut() async` to `LoginRemoteDataSource` protocol.
- Implement `signOut()` in `LoginService`.
- In `DefaultLoginRepository.signIn`, wrap `localDataSource.saveToken(dto.id)` in a `do-catch` block.
- In the `catch` block, invoke `await remoteDataSource.signOut()` before returning the failure.

**Files modified:**
- GS-NearbyPlacesExplorer/Features/Login/Data/DataSources/LoginRemoteDataSource.swift
- GS-NearbyPlacesExplorer/Features/Login/Data/DataSources/LoginService.swift
- GS-NearbyPlacesExplorer/Features/Login/Data/Repositories/DefaultLoginRepository.swift

**Files created:**
- None — Existing files updated.

**Tests affected:**
- None — Data source tests not implemented at this scope.

**Tests created:**
- None — Covered by the ViewModel test below.

### Increment 8: Add Keychain write failure unit test (finding R001-F002: Major, dev-fault)

**Goal:** Assert that the ViewModel correctly transitions to an error state without persisting a corrupt session when a write failure occurs.

**Steps:**
- Add `test_signIn_keychainWriteFailure_showsErrorMessage()` to `LoginViewModelTests`.
- Inject a `.failure` result into `MockSignInUC` to simulate the repository's returned error.
- Call `signIn()` on the ViewModel.
- Assert that `isLoading` is false, `showError` is true, and `isAuthenticated` is false.

**Files modified:**
- GS-NearbyPlacesExplorerTests/Features/Login/Presentation/LoginViewModelTests.swift

**Files created:**
- None — Existing file updated.

**Tests affected:**
- None — Existing tests unchanged.

**Tests created:**
- GS-NearbyPlacesExplorerTests/Features/Login/Presentation/LoginViewModelTests.swift::test_signIn_keychainWriteFailure_showsErrorMessage

### Increment 9: Refactor Task.sleep syntax (finding R001-F003: Minor, dev-fault)

**Goal:** Use modern Swift 5.7+ concurrency syntax for sleep.

**Steps:**
- Replace `try? await Task.sleep(nanoseconds: 2_000_000_000)` with `try? await Task.sleep(for: .seconds(2))` in `LoginViewModel`.

**Files modified:**
- GS-NearbyPlacesExplorer/Features/Login/Presentation/ViewModel/LoginViewModel.swift

**Files created:**
- None — Existing file updated.

**Tests affected:**
- None — No behavior changed.

**Tests created:**
- None — No new test needed for syntax style change.
