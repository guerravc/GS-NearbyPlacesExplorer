---
name: "Increments Plan"
overview: "Execution breakdown for About The Place feature"
isProject: false
task_id: feature-about-place-view
version: 1.0.0
---

## Increments

### Increment 1: Configure SwiftData & Persistence Layer
- **Goal:** Define the `FavoritePlace` SwiftData model and update the `ModelContainer` in the App entry point to support it securely.
- **Steps:**
  1. Define `@Model final class FavoritePlace` with `userEmail`, `osmId`, `name`, and an `id` compound key.
     - What could go wrong: Missing `@Attribute(.unique)` causes duplicate favorites for the same user.
     - Quick verification: Build passes and schema compiles.
     - Obligations: `BND-001`.
  2. Inject `FavoritePlace.self` into the `ModelContainer` schema in `GS_NearbyPlacesExplorerApp.swift`.
     - What could go wrong: Overwriting existing schemas breaks app launch.
     - Quick verification: App launches without crashing from SwiftData context initialization errors.
     - Obligations: None.
- **Files modified:** `GS-NearbyPlacesExplorer/GS-NearbyPlacesExplorer/App/GS_NearbyPlacesExplorerApp.swift`
- **Files created:** `GS-NearbyPlacesExplorer/Features/AboutThePlace/Data/Models/FavoritePlace.swift`
- **Tests affected:** `None — App lifecycle & DB Schema`
- **Tests created:** `None — Pure declarative schema`

### Increment 2: Implement Data & Domain Layers for Networking
- **Goal:** Implement `fetchElementDetails` inside `DefaultAboutThePlaceService`, map it via the Repository to an Entity, and wrap it in `FetchPlaceDetailsUC`.
- **Steps:**
  1. Define `AboutThePlaceGateway`, `AboutThePlaceEntity`, and `FetchPlaceDetailsUC`.
     - What could go wrong: Logic is placed in the View instead of the UseCase.
     - Quick verification: UseCase only acts as a coordinator calling the Gateway.
     - Obligations: `BND-001`.
  2. Implement `DefaultAboutThePlaceService` using `APIRequestDispatching` with the specific Overpass QL query.
     - What could go wrong: Incorrectly formatting the URL-encoded query causes 400 errors.
     - Quick verification: Unit tests run a mocked response successfully.
     - Obligations: None.
  3. Implement `DefaultAboutThePlaceRepository` mapping DTOs to Entities.
     - What could go wrong: Missing fields throw decoding errors abruptly.
     - Quick verification: Fallbacks in the mapping prevent crash on incomplete OSM nodes.
     - Obligations: `FAIL-002`.
  4. Integrate an in-memory `NSCache` in `DefaultAboutThePlaceRepository` mapped by `osmId`.
     - What could go wrong: Thread safety issues during concurrent writes to NSCache.
     - Quick verification: Wrap NSCache writes/reads in thread-safe mechanisms or ensure they run serially.
     - Obligations: None.
- **Files modified:** `GS-NearbyPlacesExplorer/Features/AboutThePlace/Data/DataSource/Services/DefaultAboutThePlaceService.swift`
- **Files created:** 
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Domain/Entities/AboutThePlaceEntity.swift`
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Domain/Gateways/AboutThePlaceGateway.swift`
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Domain/UseCases/FetchPlaceDetailsUC.swift`
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Data/Repositories/DefaultAboutThePlaceRepository.swift`
- **Tests affected:** `None`
- **Tests created:** `GS-NearbyPlacesExplorerTests/Features/AboutThePlace/Data/DefaultAboutThePlaceServiceTests.swift`

### Increment 3: Implement Data & Domain Layers for Favorites
- **Goal:** Build the Gateway, Repository, and UseCases (`ToggleFavoritePlaceUC`, `CheckFavoriteStatusUC`) to interact with SwiftData for a specific `userEmail`.
- **Steps:**
  1. Define `FavoritePlaceEntity` and `FavoritePlacesGateway`.
     - What could go wrong: Domain layer imports SwiftData.
     - Quick verification: Gateway only references pure Swift structs.
     - Obligations: `BND-001`.
  2. Implement `DefaultFavoritePlacesRepository` handling SwiftData context.
     - What could go wrong: Fetch descriptors fail to filter properly by `userEmail`.
     - Quick verification: Filtering specifically requires `osmId == id && userEmail == email`.
     - Obligations: `OWN-001`.
  3. Implement `ToggleFavoritePlaceUC` and `CheckFavoriteStatusUC`.
     - What could go wrong: Toggle logic incorrectly duplicates entries.
     - Quick verification: If status is true, it deletes; if false, it inserts.
     - Obligations: None.
- **Files modified:** `None`
- **Files created:**
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Domain/Entities/FavoritePlaceEntity.swift`
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Domain/Gateways/FavoritePlacesGateway.swift`
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Data/Repositories/DefaultFavoritePlacesRepository.swift`
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Domain/UseCases/ToggleFavoritePlaceUC.swift`
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Domain/UseCases/CheckFavoriteStatusUC.swift`
- **Tests affected:** `None`
- **Tests created:** `None`

### Increment 4: Presentation Logic & ViewModel Orchestration
- **Goal:** Implement `AboutThePlaceViewModel` to handle view states, execute the fetch UC on appear, and manage the favorite state synchronously.
- **Steps:**
  1. Build `AboutThePlaceDetailModel` and define `ViewState` enum.
     - What could go wrong: View receives raw DTOs instead of presentation models.
     - Quick verification: ViewModel maps entity strictly to `AboutThePlaceDetailModel`.
     - Obligations: `BND-001`.
  2. Implement `onAppear` executing `FetchPlaceDetailsUC` and `CheckFavoriteStatusUC`.
     - What could go wrong: Unhandled errors crash the app.
     - Quick verification: Errors map cleanly to `ViewState.error`.
     - Obligations: `FAIL-001`.
  3. Implement `toggleFavorite` utilizing `ToggleFavoritePlaceUC`.
     - What could go wrong: `userEmail` is not available.
     - Quick verification: Inject `userEmail` into ViewModel upon init from Router/Parent.
     - Obligations: `OWN-001`.
- **Files modified:** `GS-NearbyPlacesExplorer/Features/AboutThePlace/Presentation/ViewModel/AboutThePlaceViewModel.swift`
- **Files created:** `GS-NearbyPlacesExplorer/Features/AboutThePlace/Presentation/Model/AboutThePlaceDetailModel.swift`
- **Tests affected:** `None`
- **Tests created:** `GS-NearbyPlacesExplorerTests/Features/AboutThePlace/Presentation/AboutThePlaceViewModelTests.swift`

### Increment 5: UI Integration & Navigation
- **Goal:** Build the exact UI matching the mockup, handle overlays, non-interactive map, fallbacks, and the NavigationLink from `NearbyPlacesView`.
- **Steps:**
  1. Modify `NearbyPlacesView` to inject `osmId` and `userEmail` into `AboutThePlaceView` via `NavigationLink`.
     - What could go wrong: TabBar remains visible unexpectedly.
     - Quick verification: Use `.toolbar(.hidden, for: .tabBar)` on the detail view.
     - Obligations: None.
  2. Implement the blocking Loading Overlay.
     - What could go wrong: Overlay doesn't block background interactions.
     - Quick verification: Apply `.allowsHitTesting(false)` to parent ZStack while loading.
     - Obligations: `INV-001`.
  3. Build the non-interactive Map and Yellow Info Boxes.
     - What could go wrong: Map absorbs scroll gestures.
     - Quick verification: Use `.disabled(true)` on the `Map`.
     - Obligations: `INV-002`.
  4. Bind Toolbar and Bottom Favorite Buttons to the same `@State` / `viewModel.isFavorite`.
     - What could go wrong: Desync between buttons.
     - Quick verification: Both buttons use the exact same variable and function call.
     - Obligations: None.
  5. Apply `withAnimation` to the state transition between `.loading` and `.loaded`.
     - What could go wrong: Abrupt pop-in of the Map view causes visual judder.
     - Quick verification: State change fades the map smoothly over the placeholder.
     - Obligations: None.
- **Files modified:** 
  - `GS-NearbyPlacesExplorer/Features/AboutThePlace/Presentation/View/AboutThePlaceView.swift`
  - `GS-NearbyPlacesExplorer/Features/NearbyPlaces/Presentation/View/NearbyPlacesView.swift`
- **Files created:** `None`
- **Tests affected:** `None`
- **Tests created:** `None`

## Improvement Margin
- (Improvements incorporated into increments).

## Self Code Review
(This section will be populated during the `/implement` phase as each increment is completed).

### Increment Outcome: Increment 1 — Configure SwiftData & Persistence Layer

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::Increment 1 **Goal:** | Defined `@Model final class FavoritePlace` and added to `GS_NearbyPlacesExplorerApp` schema | pass |
| Applicable invariants verified | required — BND-001 (Domain Isolation) | `FavoritePlace` is in Data layer, schema defines uniquely `id` | pass |
| Boundary/dependency direction verified | not applicable — pure Data layer schema, no cross-layer DTOs | N/A | n/a |
| Failure/stale/cancel/rollback paths verified | not applicable — declarative schema only | N/A | n/a |

### Increment Verification: Increment 1 — Configure SwiftData & Persistence Layer

Mechanism: Xcode MCP (`BuildProject`, `RunAllTests`)
Build: SUCCESS
Tests (full suite): 46 passed, 0 failed
Styleguides: clean — validated against `docs/STYLEGUIDE-ARCHITECTURE.md` and `docs/STYLEGUIDE.md`

### Increment Outcome: Increment 2 — Implement Data & Domain Layers for Networking

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::Increment 2 **Goal:** | Implemented `FetchPlaceDetailsUC`, `AboutThePlaceGateway`, `DefaultAboutThePlaceRepository`, and `DefaultAboutThePlaceService` | pass |
| Applicable invariants verified | required — FAIL-002 (Missing Data Fallback) | Map maps optional tags to safely unwrap or fallback string `"Unknown"` and `0.0` lat/lon | pass |
| Boundary/dependency direction verified | required — Architecture Styleguide | Domain layer only imports Foundation, doesn't depend on networking DTOs | pass |
| Failure/stale/cancel/rollback paths verified | required — NSCache thread safety | Cache writes/reads are wrapped in `NSLock()` | pass |

### Increment Verification: Increment 2 — Implement Data & Domain Layers for Networking

Mechanism: Xcode MCP (`RunSomeTests`)
Build: SUCCESS
Tests (scoped): 1 passed (`DefaultAboutThePlaceServiceTests`)
Styleguides: clean — validated against `docs/STYLEGUIDE-ARCHITECTURE.md` and `docs/STYLEGUIDE.md`

### Increment Outcome: Increment 4 — Presentation Logic & ViewModel Orchestration

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::Increment 4 **Goal:** | Implemented `AboutThePlaceViewModel` managing `AboutThePlaceViewState` | pass |
| Applicable invariants verified | required — BND-001 (Domain Isolation) | ViewModel correctly wraps `AboutThePlaceEntity` into `AboutThePlaceDetailModel` | pass |
| Boundary/dependency direction verified | required — Architecture | ViewModel uses UseCases to orchestrate business logic | pass |
| Failure/stale/cancel/rollback paths verified | required — FAIL-001 | State sets to `.error` when fetch details fails | pass |

### Increment Verification: Increment 4 — Presentation Logic & ViewModel Orchestration

Mechanism: Xcode MCP (`RunSomeTests`)
Build: SUCCESS
Tests (scoped): 2 passed (`AboutThePlaceViewModelTests`)
Styleguides: clean — validated against `docs/STYLEGUIDE-ARCHITECTURE.md`

### Increment Outcome: Increment 5 — UI Integration

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::Increment 5 **Goal:** | Implemented `AboutThePlaceView` and connected it in `NearbyPlacesView` | pass |
| UI implemented | required — UI Guidelines | View displays loading, error, and loaded states with SF symbols | pass |
| Routing verified | required | `navigationDestination` correctly triggers the detail view | pass |

### Increment Verification: Increment 5 — UI Integration

Mechanism: Xcode MCP (`RunSomeTests`)
Build: SUCCESS
Tests (scoped): 2 passed (`AboutThePlaceViewModelTests`)

## Remediation increments

### Increment 6: Extract monolithic UI sections into private sub-components (finding R001-F001: Minor, dev-fault)

**Goal:** Extract distinct UI sections in `AboutThePlaceView` into private helper views to improve declarative code readability.

**Steps:**
  1. Extract the Header Map/Placeholder into a private `var headerView: some View`.
     - What could go wrong: Accidentally dropping the Map `disabled(true)` modifier.
     - Quick verification: The map remains non-interactive.
     - Obligations: `INV-002`.
  2. Extract the Rating and Status info boxes into a private `var infoBoxesView: some View`.
     - What could go wrong: Layout breaks if spacing or fixed sizes are removed.
     - Quick verification: The two yellow boxes remain perfectly symmetrical.
     - Obligations: None.
  3. Extract the bottom Favorite Button into a private `var bottomFavoriteButton: some View`.
     - What could go wrong: Button action loses its binding to the ViewModel.
     - Quick verification: Tapping the button still triggers `viewModel.toggleFavorite()`.
     - Obligations: None.
  4. Replace the inline UI code inside `body` with these newly extracted sub-components.
     - What could go wrong: Main `ZStack` hierarchy and loading overlay order gets skewed.
     - Quick verification: Overall UI visually matches the monolithic version exactly, and overlay still blocks interaction.
     - Obligations: `INV-001`.

**Files modified:**
- `GS-NearbyPlacesExplorer/Features/AboutThePlace/Presentation/View/AboutThePlaceView.swift`

**Files created:**
- None — inline extraction to private properties.

**Tests affected:**
- None — purely structural UI refactor without behavioral changes.

**Tests created:**
- None — UI remains covered by existing tests and previews.

### Increment Outcome: Increment 6 — Extract monolithic UI sections into private sub-components

| Semantic check | Applicability and obligation source | Concrete evidence | Result |
|---|---|---|---|
| Goal achieved | required — increments.plan.md::Increment 6 **Goal:** | View extracted into `headerView`, `infoBoxesView`, `bottomFavoriteButton` in `AboutThePlaceView.swift:L232-315` | pass |
| Applicable invariants verified | required — increments.plan.md::Increment 6 **Obligations:** | `INV-002` verified in `AboutThePlaceView.swift:L240` (`.disabled(true)` kept), `INV-001` verified in `AboutThePlaceView.swift:L188` (`.allowsHitTesting(false)` kept) | pass |
| Boundary/dependency direction verified | not applicable — touched-scope: pure SwiftUI internal structural refactoring | N/A rationale: no cross-layer or domain dependencies added | n/a |
| Failure/stale/cancel/rollback paths verified | not applicable — touched-scope: pure SwiftUI internal structural refactoring | N/A rationale: no mutation or concurrency changes | n/a |

### Increment Verification: Increment 6 — Extract monolithic UI sections into private sub-components

Mechanism: Xcode MCP (`RunAllTests` as scoped fallback)
Build: SUCCESS
Tests (scoped): 49 passed (`GS-NearbyPlacesExplorerTests`)
Styleguides: clean — validated against: docs/
