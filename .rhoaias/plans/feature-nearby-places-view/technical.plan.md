---
name: "Technical Plan"
overview: "Architecture and technical plan for Nearby Places"
isProject: false
todos:
  - id: nav-link-gap
    content: "Missing NavigationLink routing to AboutThePlaceView in increments"
    status: completed
    kind: validation
    artifact: increments.plan.md
    dimension: Definition Alignment
    proposed_resolution: "Add explicit step in Increment 4 to wrap PlaceListCell in a NavigationLink pointing to AboutThePlaceView."
  - id: locate-me-gap
    content: "Missing Locate Me (location.fill) floating button in Map view increment"
    status: completed
    kind: validation
    artifact: increments.plan.md
    dimension: Definition Alignment
    proposed_resolution: "Add explicit step in Increment 4 to include a floating button on the map that calls LocationManager to recenter coordinates."
  - id: cleanup-dup-inc7
    content: "Duplicate Increment 7 blocks in increments.plan.md due to bad patch"
    status: completed
    kind: validation
    artifact: increments.plan.md
    dimension: Planning
    proposed_resolution: "Remove the corrupted/duplicate Increment 7 text blocks and keep only the cleanly formatted one."
  - id: a11y-out-of-scope
    content: "Remove Accessibility (VoiceOver) requirements from scope"
    status: completed
    kind: validation
    artifact: multiple
    dimension: Definition Alignment
    proposed_resolution: "Remove A11y criteria from dor.plan.md, dod.plan.md, analysis.product.md, and specs.design.md. Explicitly declare A11y/VoiceOver in the Out of Scope section of dor.plan.md."
---

## Problem Framing
Currently, the "Vista 2" (Nearby Places View) exists only as boilerplate files. We need to build a dynamic Map and List exploration interface that consumes MapKit (`MKLocalSearch`) and CoreLocation to help users discover nearby points of interest. This matters because it provides the core value proposition of the app: seamless and immediate local discovery. The desired behavior is a searchable `TabView` that retains its state across tabs, prevents concurrent network race conditions via an overlay, handles permissions gracefully, and relies on a strict static visual mapper to render SF Symbols based on the category.

## Architecture and Approach

- **Pattern:** Clean Architecture (Data, Domain, Presentation layers) with MVVM and SwiftUI Observation.
- **Async model:** Swift 5.7+ `async/await` for MapKit searches and location fetching.
- **Location Management:** A dedicated `@Observable` `LocationManager` wrapping `CLLocationManager` in the AppCore module.
- **Data Layer:** `DefaultNearbyPlacesService` encapsulates `MKLocalSearch` using modern iOS 26 `MKMapItem.location` and returns `NearbyPlacesDTO`. `DefaultNearbyPlacesRepository` maps DTOs to Domain `NearbyPlacesEntity`.
- **Domain Layer:** `FetchNearbyPlacesUC` is the Use Case invoked by the ViewModel to retrieve entities via the `NearbyPlacesGateway` interface.
- **Authentication Initialization:** `HasStoredSessionUC` orchestrates silent background session validation during app launch to prevent UI flickering on the Login screen.
- **Presentation Layer:** `NearbyPlacesViewModel` holds the search state (`query`, `results`, `isLoading`), mapping `NearbyPlacesEntity` to `NearbyPlacesModel`. The view layer remains completely decoupled from `MKMapItem`.
- **Navigation & Search Architecture (iOS 18+):** A native `TabView` structure with dedicated tabs. The Search Tab (`role: .search`) preserves the previous content context (`lastContentTab`) and utilizes `.searchable(isPresented:)` natively instead of global `NavigationStack` wrappers or `@FocusState` hacks.
- **State Consistency (Map):** The map utilizes `MapCameraPosition` to prevent "zoom out" resets when the view hierarchy shifts. State is shared seamlessly between the Map Tab and Search Tab overlays.
- **State Consistency (List):** Scroll position synchronization across instances relies on local view anchors tracking visible indices, avoiding infinite loops caused by inactive views overwriting global state.
- **INV-001 — Blocking UX:** A translucid overlay with `ProgressView` MUST intercept user interactions while the Use Case is in flight.
- **INV-002 — State Consistency:** Tab selection changes MUST NOT refetch data or clear the current search results in the ViewModel.
- **BND-001 — Mapper Decoupling:** `MKPointOfInterestCategory` mapping MUST be handled by a dedicated non-UI utility (`POICategoryMapper`). UI Views MUST NOT contain explicit category to symbol mapping.
- **OWN-001 — Location Ownership:** `LocationManager` is the single source of truth for location permissions and coordinates.
- **OWN-002 — Data Fetching Ownership:** `DefaultNearbyPlacesService` is the sole orchestrator of `MKLocalSearch` requests.
- **FAIL-001 — Missing Location:** Location permission denial MUST trigger the specific "Ubicación necesaria" alert.
- **FAIL-002 — Network Failure:** Network errors or empty responses MUST trigger the specific exact strings defined by product.

## File Structure and Visualization

### Files to create
- `GS-NearbyPlacesExplorer/AppCore/Location/LocationManager.swift`
- `GS-NearbyPlacesExplorer/AppCore/Utils/POICategoryMapper.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/Components/NearbyPlacesMapView.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/Components/NearbyPlacesListView.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/Components/PlaceListCell.swift`
- `GS-NearbyPlacesExplorerTests/Features/NearbyPlaces/Presentation/NearbyPlacesViewModelTests.swift`
- `GS-NearbyPlacesExplorerTests/AppCore/Utils/POICategoryMapperTests.swift`

### Files to modify
- `GS-NearbyPlacesExplorer/Info.plist`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/DataSource/Services/DefaultNearbyPlacesService.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/Repositories/DefaultNearbyPlacesRepository.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/Models/NearbyPlacesDTO.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/Entities/NearbyPlacesEntity.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/Gateways/NearbyPlacesGateway.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/UseCases/FetchNearbyPlacesUC.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/Model/NearbyPlacesModel.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/ViewModel/NearbyPlacesViewModel.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/NearbyPlacesView.swift`

### Dependencies to verify/add
- `MapKit` (Native)
- `CoreLocation` (Native)

### Architecture and flow diagrams

```mermaid
graph TD
    V[NearbyPlacesView] --> VM[NearbyPlacesViewModel]
    V --> LM[LocationManager]
    VM -->|invoke| UC[FetchNearbyPlacesUC]
    UC -->|fetch| GW(NearbyPlacesGateway)
    REPO[DefaultNearbyPlacesRepository] -.->|implements| GW
    REPO -->|fetch| SVC[DefaultNearbyPlacesService]
    SVC -->|query| MK[MKLocalSearch]
    MK -.->|Array of MKMapItem| SVC
    SVC -.->|NearbyPlacesDTO| REPO
    REPO -.->|NearbyPlacesEntity| UC
    UC -.->|NearbyPlacesEntity| VM
    VM -->|Transforms Categories| PCM[POICategoryMapper]
    PCM -.->|SF Symbol string| VM
    VM -.->|NearbyPlacesModel| V
```
