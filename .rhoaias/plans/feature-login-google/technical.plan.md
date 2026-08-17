---
name: "Technical Plan Validation Backlog"
overview: "Validation and amendment TODOs for feature-login-google."
isProject: false
todos:
  - id: "amd-dor-auto-login"
    content: "- **Functional**: Auto-Login must be handled via `restorePreviousSignIn`."
    status: completed
    kind: amendment_dor
    artifact: dor.plan.md
    dimension: Functional
    source_artifact: technical.plan.md
    source_section: "## Proposed DoR Amendments"
    source_bullet: "- **Functional**: Auto-Login must be handled via `restorePreviousSignIn`."
  - id: "amd-dor-url-scheme"
    content: "- **Technical constraints**: URL Scheme configuration for GoogleSignIn must be verified."
    status: completed
    kind: amendment_dor
    artifact: dor.plan.md
    dimension: Technical constraints
    source_artifact: technical.plan.md
    source_section: "## Proposed DoR Amendments"
    source_bullet: "- **Technical constraints**: URL Scheme configuration for GoogleSignIn must be verified."
  - id: "amd-dor-keychain-fail"
    content: "- **Security**: Keychain write failure handling."
    status: completed
    kind: amendment_dor
    artifact: dor.plan.md
    dimension: Security
    source_artifact: technical.plan.md
    source_section: "## Proposed DoR Amendments"
    source_bullet: "- **Security**: Keychain write failure handling."
  - id: "amd-dod-auto-login"
    content: "- **Test criteria**: Verify Auto-Login flow."
    status: completed
    kind: amendment_dod
    artifact: dod.plan.md
    dimension: Test criteria
    source_artifact: technical.plan.md
    source_section: "## Proposed DoD Amendments"
    source_bullet: "- **Test criteria**: Verify Auto-Login flow."
  - id: "amd-dod-url-scheme"
    content: "- **Test criteria**: Verify URL Scheme configuration."
    status: completed
    kind: amendment_dod
    artifact: dod.plan.md
    dimension: Test criteria
    source_artifact: technical.plan.md
    source_section: "## Proposed DoD Amendments"
    source_bullet: "- **Test criteria**: Verify URL Scheme configuration."
  - id: "amd-dod-keychain-fail"
    content: "- **Test criteria**: Verify Keychain write failure."
    status: completed
    kind: amendment_dod
    artifact: dod.plan.md
    dimension: Test criteria
    source_artifact: technical.plan.md
    source_section: "## Proposed DoD Amendments"
    source_bullet: "- **Test criteria**: Verify Keychain write failure."
  - id: "val-renumber-increments"
    content: "Renumber increments — non-consecutive numbering and/or alphabetic suffixes detected."
    status: completed
    kind: validation
    artifact: increments.plan.md
    dimension: Planning
    proposed_resolution: |
      Rename headings in document order:
        - '### Increment 6: Enforce session revert on Keychain failure (finding R001-F001: Critical, dev-fault)' -> '### Increment 7: Enforce session revert on Keychain failure (finding R001-F001: Critical, dev-fault)'
        - '### Increment 7: Add Keychain write failure unit test (finding R001-F002: Major, dev-fault)' -> '### Increment 8: Add Keychain write failure unit test (finding R001-F002: Major, dev-fault)'
        - '### Increment 8: Refactor Task.sleep syntax (finding R001-F003: Minor, dev-fault)' -> '### Increment 9: Refactor Task.sleep syntax (finding R001-F003: Minor, dev-fault)'
      Update frontmatter `todos` so its order matches the new heading sequence.
  - id: "val-align-frontmatter-todos"
    content: "Align frontmatter todos order with renamed Increment headings (execution order is the frontmatter sequence per /implement v1.2.2+)."
    status: completed
    kind: validation
    artifact: increments.plan.md
    dimension: Planning
    proposed_resolution: "Align frontmatter todos order with renamed Increment headings."
---

## Problem Framing
- We need to implement a Google SignIn flow for the application using SwiftUI and the GoogleSignIn SDK via SPM.
- This matters because it provides the primary authentication gateway for the user to access the app's core features securely.
- Currently, there is no login logic; the desired behavior is an authenticated state that securely stores the session in Keychain and navigates smoothly (cross-fade) to the next view after displaying the user's profile for 2 seconds.

## Architecture and Approach

- **Pattern:** MVVM with Clean Architecture + SwiftUI Navigation Router.
- **Layers involved:**
  - **Presentation:** `LoginView` (SwiftUI), `LoginTransitoryView`, `LoginViewModel` (State management, error handling, 2s timer), `AppRouter` (Navigation management via `NavigationPath`).
  - **Domain:** `AuthUseCase` (Coordinates Google SignIn logic).
  - **Data:** `KeychainRepository` (Secure persistence of session tokens).

### Architecture Flow Diagram
```mermaid
graph TD
    V[LoginView] --> VM[LoginViewModel]
    VM -->|Requests Auth| UC[AuthUseCase]
    UC -->|Invokes SDK| G[GoogleSignIn SDK]
    G -.->|Returns Tokens| UC
    UC -->|Stores Tokens| KR[KeychainRepository]
    UC -.->|Returns Entity| VM
    VM -->|Transitions State| TV[LoginTransitoryView]
    VM -->|2s Delay| R[AppRouter]
    R -->|Pushes| NP[NearbyPlacesView]
```

### User Flow Diagram
```mermaid
stateDiagram-v2
    [*] --> LoginView
    LoginView --> Loading : Tap "Continuar con Google"
    Loading --> TransitoryView : Auth OK (Cross-fade)
    Loading --> LoginView : User Cancelled
    Loading --> ErrorAlert : Network Error
    ErrorAlert --> LoginView : Tap "OK"
    TransitoryView --> NearbyPlacesView : 2s Delay (Router Push)
```

- **Dependencies to verify/add:**
  - `GoogleSignIn` (via Swift Package Manager).

- **Plan Obligations:**
  - `INV-001` (Security): Session tokens MUST be stored securely in Keychain, never in UserDefaults or plain text.
  - `INV-002` (UX Timing): The profile display post-login MUST last exactly 2 seconds before navigating.
  - `BND-001` (Architecture): The `GoogleSignIn` SDK import MUST NOT leak into the Presentation layer. `AuthUseCase` abstracts it.
  - `OWN-001` (State): `LoginViewModel` is the sole source of truth for the View's state (Idle, Loading, Success, Error). `AppRouter` is the sole source of truth for navigation state.
  - `FAIL-001` (Network): A network error MUST yield the specific alert "Error de red. Inténtalo de nuevo."
  - `FAIL-002` (Cancellation): User cancellation MUST return the view silently to the initial state without errors.

## File Structure and Visualization

### Files to Create
- `GS-NearbyPlacesExplorer/AppCore/Navigation/AppRouter.swift`
- `GS-NearbyPlacesExplorer/Features/Login/Data/Repositories/KeychainRepository.swift`
- `GS-NearbyPlacesExplorer/Features/Login/Domain/UseCases/AuthUseCase.swift`
- `GS-NearbyPlacesExplorer/Features/Login/Presentation/ViewModels/LoginViewModel.swift`
- `GS-NearbyPlacesExplorer/Features/Login/Presentation/Views/LoginView.swift`
- `GS-NearbyPlacesExplorer/Features/Login/Presentation/Views/LoginTransitoryView.swift`
- `GS-NearbyPlacesExplorerTests/Features/Login/Data/KeychainRepositoryTests.swift`
- `GS-NearbyPlacesExplorerTests/Features/Login/Domain/AuthUseCaseTests.swift`
- `GS-NearbyPlacesExplorerTests/Features/Login/Presentation/LoginViewModelTests.swift`

### Files to Modify
- `GS-NearbyPlacesExplorer.xcodeproj/project.pbxproj` (Add SPM Dependency)
- `GS-NearbyPlacesExplorer/AppCore/App/GS_NearbyPlacesExplorerApp.swift` (Inject `AppRouter` and setup `NavigationStack`)

### Directory Tree Visualization
```text
GS-NearbyPlacesExplorer/
└── Features/
    └── Login/
        ├── Data/
        │   └── Repositories/
        │       └── KeychainRepository.swift
        ├── Domain/
        │   └── UseCases/
        │       └── AuthUseCase.swift
        └── Presentation/
            ├── Views/
            │   ├── LoginView.swift
            │   └── LoginTransitoryView.swift
            └── ViewModels/
                └── LoginViewModel.swift
```
