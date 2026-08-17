---
name: Nearby Places Feature
overview: Implement Clean Architecture layers (Data, Domain, Presentation) for Nearby Places, consuming MKLocalSearch via Use Cases, and presenting a Map/List TabView with location permissions.
isProject: false
todos:
- id: 1
  content: Create LocationManager & Info.plist Config
  status: completed
- id: 2
  content: Implement Data & Domain Layers (Service, Repository, UseCase)
  status: completed
- id: 3
  content: Implement POICategoryMapper (AppCore)
  status: completed
- id: 4
  content: Develop Presentation Primitives (Map, List, Cell)
  status: completed
- id: 5
  content: Implement NearbyPlacesViewModel State & Orchestration
  status: completed
- id: 6
  content: Integrate Root View (TabView, Overlay, Alerts)
  status: completed
- id: 7
  content: Implement Logout Functionality
  status: completed
- id: '8'
  content: 'Increment 8: Fix searchable prompt string'
  status: pending
- id: '9'
  content: 'Increment 9: Fix location denied title string'
  status: pending
- id: '10'
  content: 'Increment 10: Setup Environment Configuration (.xcconfig)'
  status: pending
- id: '11'
  content: 'Increment 11: Implement APIConfiguration User-Agent Header'
  status: pending
- id: '12'
  content: 'Increment 12: Implement OSMOpeningHoursParser'
  status: pending
- id: '13'
  content: 'Increment 13: Migrate NearbyPlacesService to Overpass API'
  status: pending
- id: '14'
  content: 'Increment 14: Map dynamic opening_hours to PlaceListCell UI'
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

### Increment Outcome: 1 — Create LocationManager & Info.plist Config

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::1 **Goal:** | `GS-NearbyPlacesExplorer/AppCore/Location/LocationManager.swift` | pass |
| Applicable invariants verified | required — OWN-001, FAIL-001 | `LocationManager.swift` is `@MainActor` and maps `authorizationStatus` | pass |
| Boundary/dependency direction verified | not applicable — internal wrapper component not crossing architectural layers | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | required — Location denial (FAIL-001) | `LocationManager.swift` correctly sets `isDenied = true` on `.denied` | pass |

### Increment Outcome: 2 — Implement Data & Domain Layers

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::2 **Goal:** | Data & Domain layers implemented (`DefaultNearbyPlacesService`, `FetchNearbyPlacesUC`) | pass |
| Applicable invariants verified | required — OWN-002, BND-001 | `MKLocalSearch` is strictly inside `DefaultNearbyPlacesService`. `NearbyPlacesGateway` and `NearbyPlacesEntity` have no MapKit import. `FetchNearbyPlacesUC` is a pure passthrough. | pass |
| Boundary/dependency direction verified | required — Domain must not depend on Data | `FetchNearbyPlacesUC` depends on `NearbyPlacesGateway` protocol. `DefaultNearbyPlacesRepository` adopts it. | pass |
| Failure/stale/cancel/rollback paths verified | not applicable — no specific failure path in this increment | N/A | n/a |

### Increment Outcome: 3 — Implement POICategoryMapper

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::3 **Goal:** | `POICategoryMapper` enum maps 15+ categories | pass |
| Applicable invariants verified | required — BND-001 | Fallback `mappin.and.ellipse` and tests written. MapKit types not imported in logic directly. | pass |
| Boundary/dependency direction verified | not applicable — internal utility | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | not applicable — pure functional map | N/A | n/a |

### Increment Outcome: 4 — Develop Presentation Primitives

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::4 **Goal:** | Created `NearbyPlacesMapView`, `NearbyPlacesListView`, `PlaceListCell`, and `NearbyPlacesModel` | pass |
| Applicable invariants verified | required — BND-001, INV-002 | `PlaceListCell` uses `.red.opacity(0.15)`. Views only consume `NearbyPlacesModel`. | pass |
| Boundary/dependency direction verified | required — Presentation primitives must not leak MapKit | UI only expects `NearbyPlacesModel` | pass |
| Failure/stale/cancel/rollback paths verified | not applicable | N/A | n/a |

### Increment Outcome: 5 — Implement NearbyPlacesViewModel State & Orchestration

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::5 **Goal:** | Created `NearbyPlacesViewModel` and wired state transitions | pass |
| Applicable invariants verified | required — INV-002, FAIL-002 | `state` manages loading, success, and `.empty`. `.empty` maps Domain empties to product strings. | pass |
| Boundary/dependency direction verified | not applicable | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | required — FAIL-002 | Empty arrays trigger specific empty states with queries. Tests passed. | pass |

### Increment Outcome: 6 — Integrate Root View

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::6 **Goal:** | Integrated `NearbyPlacesView` with `LocationManager`, SegmentedControl, Overlays. | pass |
| Applicable invariants verified | required — INV-001, FAIL-001 | `.allowsHitTesting(false)` added to `loadingOverlay`. `isDenied` renders retry view. | pass |
| Boundary/dependency direction verified | not applicable | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | required — FAIL-001 | Location denied paths verified via `locationManager.isDenied`. | pass |

### Increment Outcome: 7 — Implement Logout Functionality

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::7 **Goal:** | Added logout button to Toolbar resetting `AppRouter` and deleting token. | pass |
| Applicable invariants verified | required — BND-001 | `AppRouter` injects closure, preventing `NearbyPlaces` from importing `Login` directly. | pass |
| Boundary/dependency direction verified | required — BND-001 | `NearbyPlacesView` triggers `router.performLogout?()`, unaware of TokenStorage. | pass |
| Failure/stale/cancel/rollback paths verified | not applicable | N/A | n/a |

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

### Increment Verification: 1 — Create LocationManager & Info.plist Config
- **Scoped tests:** None affected or created. Full suite run as scoped fallback.
- **Result:** Build passed. 18 tests passed, 0 failed.
- **Oracles:** Manual verification for FAIL-001 will be needed in Increment 6.

### Increment Verification: 2 — Implement Data & Domain Layers
- **Scoped tests:** None affected or created. Full suite run as scoped fallback.
- **Result:** Build passed. 18 tests passed, 0 failed.
- **Oracles:** None requested for manual test here.

### Increment Verification: 3 — Implement POICategoryMapper
- **Scoped tests:** Unit tests written (`POICategoryMapperTests.swift`).
- **Result:** Build passed. 21 tests passed (including new tests), 0 failed.
- **Oracles:** Exhaustive switch test oracle satisfied.

### Increment Verification: 4 — Develop Presentation Primitives
- **Scoped tests:** None affected or created. Full suite run as scoped fallback.
- **Result:** Build passed. 21 tests passed, 0 failed.
- **Oracles:** BND-001 formatting inspected manually in the code (.red.opacity(0.15)).

### Increment Verification: 5 — Implement NearbyPlacesViewModel State & Orchestration
- **Scoped tests:** Created `NearbyPlacesViewModelTests.swift` testing state transitions.
- **Result:** Build passed. 25 tests passed (including new tests), 0 failed.
- **Oracles:** FAIL-002 automated test oracle fulfilled correctly mapping Domain errors to view empty strings.

### Increment Verification: 6 — Integrate Root View
- **Scoped tests:** None affected or created. Full suite run as scoped fallback.
- **Result:** Build passed. 25 tests passed, 0 failed.
- **Oracles:** Manual review on INV-001 (.allowsHitTesting(false)) and FAIL-001 (Location permission error view).

### Increment Verification: 7 — Implement Logout Functionality
- **Scoped tests:** None created, logic resides in SwiftUI environment closures mapping boundaries. Full suite run as scoped fallback.
- **Result:** Build passed. 25 tests passed, 0 failed.
- **Oracles:** Manual review on BND-001 boundary separation verifying `NearbyPlaces` does not import `Login` or `LoginStorage`.

- **Coverage Mapping:**

| Behavior / Failure | Obligation | Test Layer | Assertion / Oracle |
|---|---|---|---|
| Search race conditions | INV-001 | Unit | Calling `search` while `isLoading` is true drops the request in ViewModel. |
| Tab state retention | INV-002 | Manual | Tab toggles do not fire `onAppear` fetches on sub-views. |
| Category fallback | BND-001 | Unit | Mapper returns `mappin.and.ellipse` for unknown categories. |
| Location denial alert | FAIL-001 | Manual | Mocking location denial flips the UI presentation state for the alert. |
| Empty search results | FAIL-002 | Unit | Empty response from Use Case translates strictly to "No encontramos resultados...". |

## Remediation increments

### Increment 8: Fix searchable prompt string (finding R001-F001: Minor, dev-fault)

**Goal:** Modify the `.searchable` prompt to exactly match the DoD requirement; verified by UI displaying the exact string.

**Steps:**
1. Modify `NearbyPlacesView.swift` to change the `prompt` parameter of `.searchable` from `"Buscar lugares"` to `"Buscar lugares cercanos"`.

**Files modified:**
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/NearbyPlacesView.swift`

**Files created:**
- None — no new files needed

**Tests affected:**
- None — no existing tests are impacted by this change

**Tests created:**
- None — no new tests required for this scope

### Increment 9: Fix location denied title string (finding R001-F002: Minor, dev-fault)

**Goal:** Update the location denied view title to exactly match the DoD requirement; verified by UI displaying the exact string when location is denied.

**Steps:**
1. Modify `NearbyPlacesView.swift` to change the `Text` view in `locationDeniedView` from `"Ubicación Denegada"` to `"Ubicación necesaria"`.

**Files modified:**
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/NearbyPlacesView.swift`

**Files created:**
- None — no new files needed

**Tests affected:**
- None — no existing tests are impacted by this change

**Tests created:**
- None — no new tests required for this scope

### Increment 10: Setup Environment Configuration (.xcconfig) (finding R003-F001: Major, plan-fault)

**Goal:** Create `.xcconfig` environment files and map API URLs into `AppConfiguration`; verified by `AppConfiguration` returning valid URLs in tests.

**Steps:**
1. Create `Debug.xcconfig` and `Release.xcconfig` files defining `API_SCHEME=https`, `API_HOST=overpass-api.de`, and `API_BASE_PATH=/api/interpreter`.
   - What could go wrong: Typos in xcconfig files prevent the app from building or loading variables.
   - Quick verification: Compile the app and ensure `Bundle.main.infoDictionary` contains the keys.
   - Obligations: None.
2. Map these variables to `Info.plist` keys matching `AppConfiguration.InfoKey`.
   - What could go wrong: `Info.plist` mapping uses incorrect syntax (e.g. missing `$()`).
   - Quick verification: Xcode displays the correctly evaluated variables in the target's Info tab.
   - Obligations: None.
3. Add accessors in `AppConfiguration.swift`.
   - What could go wrong: `AppConfiguration` forcibly unwraps missing keys causing a crash.
   - Quick verification: Unit tests verify `AppConfiguration.apiBaseURL` constructs safely.
   - Obligations: None.

**Files modified:**
- `GS-NearbyPlacesExplorer/Info.plist`
- `GS-NearbyPlacesExplorer/Networking/Configuration/AppConfiguration.swift`

**Files created:**
- `Config/Debug.xcconfig`
- `Config/Release.xcconfig`

**Tests affected:**
- None — no existing tests are impacted by this change

**Tests created:**
- `GS-NearbyPlacesExplorerTests/Networking/Configuration/AppConfigurationTests.swift`

### Increment 11: Implement APIConfiguration User-Agent Header (finding R003-F002: Major, plan-fault)

**Goal:** Append a globally constructed `User-Agent` to `DefaultHTTPConfiguration` headers using `AppInfo`; verified by unit tests asserting the `User-Agent` header exists.

**Steps:**
1. In `APIConfiguration.swift`, modify `DefaultHTTPConfiguration.headers` to include a `User-Agent` constructed using `AppInfo.appName`, `AppInfo.shortVersion`, and `AppInfo.osName`.
   - What could go wrong: Special characters in AppInfo fields create an invalid HTTP header.
   - Quick verification: The constructed string is URL-safe or strictly alphanumeric.
   - Obligations: None.

**Files modified:**
- `GS-NearbyPlacesExplorer/Networking/Configuration/APIConfiguration.swift`

**Files created:**
- None — no new files needed

**Tests affected:**
- None — no existing tests are impacted by this change

**Tests created:**
- `GS-NearbyPlacesExplorerTests/Networking/Configuration/APIConfigurationTests.swift`

### Increment 12: Implement OSMOpeningHoursParser (finding R003-F003: Major, plan-fault)

**Goal:** Implement an `OSMOpeningHoursParser` utility to map the 5 specific OSM time strings to an Enum with three states (`open`, `closed`, `notAvailable`); verified by exhaustive unit test coverage of the 5 scenarios.

**Steps:**
1. Create `OSMOpeningHoursParser.swift` defining the state Enum (`open`, `closed`, `notAvailable`).
   - What could go wrong: The parser logic is placed inside a View or Service layer.
   - Quick verification: The parser is an isolated, pure Swift structure in the Domain layer.
   - Obligations: BND-001.
2. Implement parsing logic explicitly supporting: "Mo-Fr 08:00-17:00", "Mo-Fr 08:00-12:00,13:00-17:30", "Mo,We 08:00-12:00", and "Mo-Fr 08:00-12:00,13:00-17:30; Sa 08:00-12:00" mapping them to the `open` or `closed` states of the Enum.
   - What could go wrong: The regex or string splitting logic is too brittle and fails on unexpected whitespace.
   - Quick verification: Unit tests cover edge cases for spacing.
   - Obligations: None.
3. Add a fallback that returns the `notAvailable` Enum state for any other format.
   - What could go wrong: Fallback throws an error instead of gracefully returning `notAvailable`.
   - Quick verification: Passing a random string returns `notAvailable` immediately.
   - Obligations: None.

**Files modified:**
- None — no existing files require changes

**Files created:**
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/Utils/OSMOpeningHoursParser.swift`

**Tests affected:**
- None — no existing tests are impacted by this change

**Tests created:**
- `GS-NearbyPlacesExplorerTests/Features/NearbyPlaces/Domain/Utils/OSMOpeningHoursParserTests.swift`

### Increment 13: Migrate NearbyPlacesService to Overpass API (finding R002-F001: Major, plan-fault)

**Goal:** Migrate `MKLocalSearch` to `APIRequestDispatcher` and `NearbyPlacesAPIRouter` to fetch POIs via Overpass API; verified by mocked unit tests returning `NearbyPlacesEntity` arrays.

**Steps:**
1. Implement `OverpassResponse` DTO and `NearbyPlacesAPIRouter` utilizing `AppConfiguration` endpoints.
   - What could go wrong: The `OverpassQL` query body is malformed.
   - Quick verification: `NearbyPlacesAPIRouter` correctly formats the POST body via `APIRequestBuilder`.
   - Obligations: OWN-002.
2. Inject `APIRequestDispatching` into `DefaultNearbyPlacesService`.
   - What could go wrong: Over-injection causes circular dependencies or tests fail to compile.
   - Quick verification: Dependency is injected via initializer, `MKLocalSearch` dependencies are removed.
   - Obligations: BND-001.
3. Fetch data using the dispatcher, parse `opening_hours` using `OSMOpeningHoursParser`, and map `OSMElement` to `NearbyPlacesEntity`.
   - What could go wrong: Missing `opening_hours` tags crash the DTO decoder.
   - Quick verification: `opening_hours` is marked as optional in `OSMElement`.
   - Obligations: None.

**Files modified:**
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/DataSource/Services/DefaultNearbyPlacesService.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Domain/Entities/NearbyPlacesEntity.swift`

**Files created:**
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/Networking/NearbyPlacesAPIRouter.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Data/Models/OverpassResponse.swift`

**Tests affected:**
- `GS-NearbyPlacesExplorerTests/Features/NearbyPlaces/Data/NearbyPlacesServiceTests.swift`

**Tests created:**
- `GS-NearbyPlacesExplorerTests/Features/NearbyPlaces/Data/NearbyPlacesAPIRouterTests.swift`

### Increment 14: Map dynamic opening_hours to PlaceListCell UI (finding R002-F001: Major, plan-fault)

**Goal:** Update `NearbyPlacesModel` and `PlaceListCell` to propagate and render the parsed Enum state; verified by UI previews displaying the correct schedule string.

**Steps:**
1. Update `NearbyPlacesModel` to carry the Enum state (`open`, `closed`, `notAvailable`) instead of the optional boolean `isOpen`.
   - What could go wrong: Model mapping incorrectly handles the Enum default cases.
   - Quick verification: Model init handles the Enum property natively.
   - Obligations: None.
2. Update `PlaceListCell` to render "Abierto", "Cerrado" or "Horario no disponible" directly based on the Enum state cases.
   - What could go wrong: UI layout breaks due to longer text strings.
   - Quick verification: SwiftUI Preview shows correct text truncation or wrapping.
   - Obligations: None.

**Files modified:**
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/Model/NearbyPlacesModel.swift`
- `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/Components/PlaceListCell.swift`

**Files created:**
- None — no new files needed

**Tests affected:**
- None — no existing tests are impacted by this change

**Tests created:**
- None — no new tests required for this scope
