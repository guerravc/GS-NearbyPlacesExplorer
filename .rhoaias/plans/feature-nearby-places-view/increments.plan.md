---
name: "Nearby Places Feature"
overview: "Implement Clean Architecture layers (Data, Domain, Presentation) for Nearby Places, consuming MKLocalSearch via Use Cases, and presenting a Map/List TabView with location permissions."
isProject: false
todos:
  - id: 1
    content: "Create LocationManager & Info.plist Config"
    status: pending
  - id: 2
    content: "Implement Data & Domain Layers (Service, Repository, UseCase)"
    status: pending
  - id: 3
    content: "Implement POICategoryMapper (AppCore)"
    status: pending
  - id: 4
    content: "Develop Presentation Primitives (Map, List, Cell)"
    status: pending
  - id: 5
    content: "Implement NearbyPlacesViewModel State & Orchestration"
    status: pending
  - id: 6
    content: "Integrate Root View (TabView, Overlay, Alerts)"
    status: pending
  - id: 7
    content: "Implement Logout Functionality"
    status: pending
  - id: 7
    content: "Implement Logout Functionality"
    status: pending
---

## Increments

### Increment 1: Create LocationManager & Info.plist Config
- **Goal:** Implement the CoreLocation wrapper in AppCore to handle permissions (`OWN-001`), surfacing denials reliably (`FAIL-001`).
- **Steps:**
  1. Add `NSLocationWhenInUseUsageDescription` to `Info.plist`.
     - What could go wrong: Missing key leads to app crash on first location request.
     - Quick verification: App does not crash when invoking `requestWhenInUseAuthorization()`.
     - Obligations: `FAIL-001`, `OWN-001`.
  2. Create `@Observable class LocationManager: NSObject, CLLocationManagerDelegate`.
     - What could go wrong: Delegate methods execute on a background thread causing UI glitches.
     - Quick verification: Enforce `@MainActor` on the class and check state updates.
     - Obligations: `OWN-001`.
- **Files modified:** `GS-NearbyPlacesExplorer/Info.plist`
- **Files created:** `GS-NearbyPlacesExplorer/AppCore/Location/LocationManager.swift`
- **Tests affected:** `None — increment only creates new files`
- **Tests created:** `None — system framework wrapper`

### Increment 2: Implement Data & Domain Layers (Service, Repository, UseCase)
- **Goal:** Implement `MKLocalSearch` strictly inside the Data layer (`OWN-002`) and bridge it to Domain via standard Clean Architecture patterns.
- **Steps:**
  1. Define `NearbyPlacesDTO` and implement `DefaultNearbyPlacesService` wrapping `MKLocalSearch`.
     - What could go wrong: Service is tightly coupled to UI threads or swallows errors.
     - Quick verification: Service returns DTOs via `async throws`.
     - Obligations: `OWN-002`.
  2. Implement `NearbyPlacesEntity`, `NearbyPlacesGateway`, and `DefaultNearbyPlacesRepository`.
     - What could go wrong: Repository leaks MapKit imports into the Domain layer.
     - Quick verification: Gateway and Entity files have NO `import MapKit`.
     - Obligations: `BND-001`.
  3. Implement `FetchNearbyPlacesUC`.
     - What could go wrong: Use case implements business logic better suited for the Repository.
     - Quick verification: UC is a pure passthrough/coordinator for the Gateway.
     - Obligations: `BND-001`.
- **Files modified:** 
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/DataSource/Services/DefaultNearbyPlacesService.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/Repositories/DefaultNearbyPlacesRepository.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/Models/NearbyPlacesDTO.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/Entities/NearbyPlacesEntity.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/Gateways/NearbyPlacesGateway.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/UseCases/FetchNearbyPlacesUC.swift`
- **Files created:** `None`
- **Tests affected:** `None`
- **Tests created:** `None`

### Increment 3: Implement POICategoryMapper (AppCore)
- **Goal:** Abstract `MKPointOfInterestCategory` to `SF Symbols` mapping into a testable utility (`BND-001`).
- **Steps:**
  1. Create `POICategoryMapper` enum mapping the required minimum 15 categories, returning `mappin.and.ellipse` as a fallback.
     - What could go wrong: Unsupported categories crash or return empty images.
     - Quick verification: Fallback covers all non-explicit categories via unit tests.
     - Obligations: `BND-001`.
- **Files modified:** `None — increment only creates new files`
- **Files created:** `GS-NearbyPlacesExplorer/AppCore/Utils/POICategoryMapper.swift`
- **Tests affected:** `None — increment only creates new files`
- **Tests created:** `GS-NearbyPlacesExplorerTests/AppCore/Utils/POICategoryMapperTests.swift`

### Increment 4: Develop Presentation Primitives (Map, List, Cell)
- **Goal:** Build the UI components `NearbyPlacesMapView`, `NearbyPlacesListView`, and `PlaceListCell` consuming only `NearbyPlacesModel` (no MapKit).
- **Steps:**
  1. Implement `NearbyPlacesModel` and `PlaceListCell`.
     - What could go wrong: Red background overlay masks text contrast.
     - Quick verification: Preview renders with red.opacity(0.15) and text is legible.
     - Obligations: `BND-001`.
  2. Implement `NearbyPlacesMapView` and `NearbyPlacesListView`.
     - What could go wrong: Views try to parse MKMapItems instead of Models.
     - Quick verification: Views only accept `[NearbyPlacesModel]`.
     - Obligations: `INV-002`.
  3. Wrap `PlaceListCell` in a `NavigationLink(value:)` and define `.navigationDestination(for:destination:)` in the parent `NavigationStack` to route to `AboutThePlaceView`.
     - What could go wrong: Using deprecated iOS 15 routing leads to unexpected navigation state.
     - Quick verification: Tap cell to ensure it pushes the new view cleanly without warnings.
     - Obligations: `BND-001`.
  4. Add a floating `location.fill` button on top of `NearbyPlacesMapView` to recenter the map using `LocationManager`.
     - What could go wrong: Button overlay blocks map interactions or ignores safe areas improperly.
     - Quick verification: Tapping the button centers the map to current coordinates.
     - Obligations: `BND-001`.
- **Files modified:** `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/Model/NearbyPlacesModel.swift`
- **Files created:**
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/Components/PlaceListCell.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/Components/NearbyPlacesMapView.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/Components/NearbyPlacesListView.swift`
- **Tests affected:** `None — UI components`
- **Tests created:** `None — UI components`

### Increment 5: Implement NearbyPlacesViewModel State & Orchestration
- **Goal:** Wire the Use Case to the Presentation state (`INV-002`) and map Domain errors to exact product strings (`FAIL-002`).
- **Steps:**
  1. Define states (`Idle`, `Loading`, `Error`, `Success`) and execute `FetchNearbyPlacesUC`.
     - What could go wrong: Missing empty state leads to blank screens.
     - Quick verification: ViewModel maps empty arrays to specific error states.
     - Obligations: `FAIL-002`.
- **Files modified:** `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/ViewModel/NearbyPlacesViewModel.swift`
- **Files created:** `None`
- **Tests affected:** `None`
- **Tests created:** `GS-NearbyPlacesExplorerTests/Features/NearbyPlaces/Presentation/NearbyPlacesViewModelTests.swift`

### Increment 6: Integrate Root View (TabView, Overlay, Alerts)
- **Goal:** Bind the ViewModel and LocationManager to the root `NearbyPlacesView`, enforcing blocking overlays (`INV-001`) and permission alerts (`FAIL-001`).
- **Steps:**
  1. Set up `NavigationStack`, `TabView`, and location alerts.
     - What could go wrong: Tab selection resets parent view state.
     - Quick verification: Switch tabs and confirm search results persist.
     - Obligations: `INV-002`, `FAIL-001`.
  2. Overlay a `ProgressView` when `viewModel.isLoading` is true.
     - What could go wrong: Overlay doesn't block interaction.
     - Quick verification: Add `.allowsHitTesting(false)` to parent container during load.
     - Obligations: `INV-001`.
- **Files modified:** `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/NearbyPlacesView.swift`
- **Files created:** `None`
- **Tests affected:** `None`
- **Tests created:** `None`

### Increment 7: Implement Logout Functionality
- **Goal:** Implement the global logout button in the root navigation bar, clearing session state and routing back to Login.
- **Steps:**
  1. Add a toolbar item to `NearbyPlacesView` with the `rectangle.portrait.and.arrow.right` icon.
     - What could go wrong: Button tapped multiple times triggers multiple state clears.
     - Quick verification: Action executes synchronously and replaces the root view state.
     - Obligations: `BND-001`.
  2. Connect the action to the App's root state manager or Firebase Auth logout.
     - What could go wrong: Auth state does not propagate to the Root View.
     - Quick verification: Tapping the button successfully shows the `LoginView`.
     - Obligations: `BND-001`.
- **Files modified:** `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/NearbyPlacesView.swift`
- **Files created:** `None`
- **Tests affected:** `None`
- **Tests created:** `None`

## Improvement Margin
- Add dynamic list animations (`withAnimation`) when rendering new results.

## Self Code Review
| Obligation | Review Oracle |
|---|---|
| INV-001 | Overlay uses `.allowsHitTesting(false)` to block UI during loading state. |
| INV-002 | `NearbyPlacesViewModel` is owned by root view; `TabView` tabs only consume models. |
| BND-001 | Domain and Presentation layers have no `import MapKit`. `POICategoryMapper` abstracts symbols. |
| OWN-001 | `LocationManager` is strictly injected and manages CoreLocation delegate callbacks on MainActor. |
| OWN-002 | `MKLocalSearch` requests exist exclusively in `DefaultNearbyPlacesService`. |
| FAIL-001 | `.alert("Ubicación necesaria")` is presented dynamically based on `LocationManager.isDenied`. |
| FAIL-002 | `NearbyPlacesViewModel` maps specific Use Case errors to exact hardcoded product strings. |

## Testing

> For per-increment test enumeration, see each increment's `**Tests affected:**` and `**Tests created:**` sub-bullets in `## Increments`. This section captures cross-cutting test strategy only.

- **Framework:** XCTest / Swift Testing.
- **Coverage Strategy:**
  - **Unit:** ViewModels must be injected with mocked Use Cases. `POICategoryMapper` requires an exhaustive switch test. Service layers require mocked network/MapKit interceptors if testable.
  - **UI / Integration:** Excluded from scope; behavior relies on SwiftUI previews.
- **Coverage Mapping:**

| Behavior / Failure | Obligation | Test Layer | Assertion / Oracle |
|---|---|---|---|
| Search race conditions | INV-001 | Unit | Calling `search` while `isLoading` is true drops the request in ViewModel. |
| Tab state retention | INV-002 | Manual | Tab toggles do not fire `onAppear` fetches on sub-views. |
| Category fallback | BND-001 | Unit | Mapper returns `mappin.and.ellipse` for unknown categories. |
| Location denial alert | FAIL-001 | Manual | Mocking location denial flips the UI presentation state for the alert. |
| Empty search results | FAIL-002 | Unit | Empty response from Use Case translates strictly to "No encontramos resultados...". |
