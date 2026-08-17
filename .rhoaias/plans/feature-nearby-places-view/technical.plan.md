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
  - id: dod-amendment-r002
    content: "- **Business Hours Data**: The hardcoded MapKit fallback string must be replaced."
    status: completed
    kind: amendment_dod
    artifact: dod.plan.md
    dimension: Business Hours Data
    proposed_resolution: Fetch `opening_hours` tag from Overpass API. Display the raw string if present, otherwise display "Horario no disponible".
    source_artifact: review.remediation.md
    source_section: "## Proposed DoD Amendments"
    source_bullet: "- **Business Hours Data**: The hardcoded MapKit fallback string must be replaced."
  - id: plan-correction-r002
    content: "- **technical.plan.md | Data Layer Architecture**: `MKLocalSearch` is obsolete."
    status: completed
    kind: validation
    artifact: technical.plan.md
    dimension: Data Layer Architecture
    proposed_resolution: Replace `MKLocalSearch` usage with `NearbyPlacesAPIRouter` (via `https://overpass-api.de/api/interpreter`) using the `APIRequestDispatcher`. Update DTOs to parse `OSMElement`.
    source_artifact: review.remediation.md
    source_section: "## Proposed Plan Corrections"
    source_bullet: "- **technical.plan.md | Data Layer Architecture**: `MKLocalSearch` is obsolete."
  - id: dod-amendment-r003
    content: "- **Business Hours Parsing**: Replace the previous amendment."
    status: completed
    kind: amendment_dod
    artifact: dod.plan.md
    dimension: Business Hours Parsing
    proposed_resolution: The `opening_hours` tag must be parsed. If it matches one of the 5 specific scenarios (Common, Multiple intervals, Multiple days same periods, Multiple days multiple periods), it must evaluate to `Bool` (Abierto/Cerrado). Any other scenario must fallback to `nil` ("Horario no disponible").
    source_artifact: review.remediation.md
    source_section: "## Proposed DoD Amendments"
    source_bullet: "- **Business Hours Parsing**: Replace the previous amendment."
  - id: plan-correction-r003
    content: "- **technical.plan.md | Network Configuration**:"
    status: completed
    kind: validation
    artifact: technical.plan.md
    dimension: Network Configuration
    proposed_resolution: Update to reflect that Overpass API URLs are supplied via `Debug.xcconfig` / `Release.xcconfig` and consumed by `AppConfiguration`, and `User-Agent` is managed by `APIConfiguration`.
    source_artifact: review.remediation.md
    source_section: "## Proposed Plan Corrections"
    source_bullet: "- **technical.plan.md | Network Configuration**:"
  - id: val-inc12-enum-gap
    content: Increment 12 goal and steps use boolean state instead of the required Enum (open, closed, notAvailable) defined in dod.plan.md.
    status: completed
    kind: validation
    artifact: increments.plan.md
    dimension: Definition Alignment
    proposed_resolution: Update Increment 12 goal and steps to parse into an Enum with three states (open, closed, notAvailable) instead of a boolean.
  - id: val-inc14-enum-gap
    content: Increment 14 uses optional boolean isOpen instead of the required Enum (open, closed, notAvailable) defined in dod.plan.md.
    status: completed
    kind: validation
    artifact: increments.plan.md
    dimension: Definition Alignment
    proposed_resolution: Update Increment 14 goal and steps to propagate and render the new Enum state rather than an optional boolean `isOpen`.
---

## Problem Framing
Currently, the "Vista 2" (Nearby Places View) exists only as boilerplate files. We need to build a dynamic Map and List exploration interface that consumes MapKit (`MKLocalSearch`) and CoreLocation to help users discover nearby points of interest. This matters because it provides the core value proposition of the app: seamless and immediate local discovery. The desired behavior is a searchable `TabView` that retains its state across tabs, prevents concurrent network race conditions via an overlay, handles permissions gracefully, and relies on a strict static visual mapper to render SF Symbols based on the category.

## Architecture and Approach

- **Pattern:** Clean Architecture (Data, Domain, Presentation layers) with MVVM and SwiftUI Observation.
- **Async model:** Swift 5.7+ `async/await` for MapKit searches and location fetching.
- **Location Management:** A dedicated `@Observable` `LocationManager` wrapping `CLLocationManager` in the AppCore module.
- **Data Layer:** `DefaultNearbyPlacesService` encapsulates `NearbyPlacesAPIRouter` (via `https://overpass-api.de/api/interpreter`) using the `APIRequestDispatcher` and returns `NearbyPlacesDTO` parsed from `OSMElement`. `DefaultNearbyPlacesRepository` maps DTOs to Domain `NearbyPlacesEntity`.
- **Domain Layer:** `FetchNearbyPlacesUC` is the Use Case invoked by the ViewModel to retrieve entities via the `NearbyPlacesGateway` interface.
- **Authentication Initialization:** `HasStoredSessionUC` orchestrates silent background session validation during app launch to prevent UI flickering on the Login screen.
- **Network Configuration:** Overpass API URLs are supplied via `Debug.xcconfig` / `Release.xcconfig` and consumed by `AppConfiguration`. The `User-Agent` is managed centrally by `APIConfiguration`.
- **Presentation Layer:** `NearbyPlacesViewModel` holds the search state (`query`, `results`, `isLoading`), mapping `NearbyPlacesEntity` to `NearbyPlacesModel`. The view layer remains completely decoupled from `MKMapItem`.
- **Navigation & Search Architecture (iOS 18+):** Currently `TabView` is the root container and wraps `NavigationStack` per tab. The Search Tab (`role: .search`) preserves the previous content context (`lastContentTab`) and utilizes `.searchable(isPresented:)` natively. The searchable placeholder is "Buscar lugares cercanos".
- **Routing Strategy:** The list handles routing to `AboutThePlaceView` using `NavigationLink`, while the map markers use another strategy to achieve the same goal. When pushing to the detail view, the tab bar is explicitly hidden.
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
