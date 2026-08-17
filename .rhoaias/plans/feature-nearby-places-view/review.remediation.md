<!-- remediation-round:start round_id=R001 -->
## Remediation Summary
- **Round ID:** R001
- **UTC:** 2026-08-16T21:24:00Z
- **Round type:** standard
- **Source/Predecessor:** self-review handoff
- **Plan cutoff increment:** 7
- **Plan SHA-256 before append:** 99af5a9d1cbdb4b1eda53d707fd84e3c6094658d8fafe5c7ac07c8b5ea04eef7
- **Command-log correlation:** `round_id=R001`
- **Context-gap carry-forward:** none
- **Reconciles:** none
- **Recovery confidence:** not-applicable
- **Recovered mappings:** none
- **Unrecoverable gaps:** none

## Diagnosis

### Finding R001-F001: Mismatched Searchable Prompt (severity: Minor)
- **Family ID:** FAM-searchable-prompt-mismatch
- **Source:** self-review adjudicated (NearbyPlacesView.swift)
- **Root cause:** dev-fault — The implementation used "Buscar lugares" instead of the exact DoD string "Buscar lugares cercanos".
- **Evidence reviewed:** `NearbyPlacesView.swift` line 95, `dod.plan.md`.
- **Pattern/architecture impact:** None beyond this finding.
- **Corrected approach:** Update the `prompt` parameter in `.searchable` to exactly match the required copy.
- **Disposition:** code_increment
- **Routed output:** Increment 8

### Finding R001-F002: Mismatched Location Denied Title (severity: Minor)
- **Family ID:** FAM-location-denied-mismatch
- **Source:** self-review adjudicated (NearbyPlacesView.swift)
- **Root cause:** dev-fault — The implementation used "Ubicación Denegada" instead of the exact DoD string "Ubicación necesaria".
- **Evidence reviewed:** `NearbyPlacesView.swift` line 192, `dod.plan.md`.
- **Pattern/architecture impact:** None beyond this finding.
- **Corrected approach:** Update the `Text` in `locationDeniedView` to exactly match the required copy.
- **Disposition:** code_increment
- **Routed output:** Increment 9

### Finding R001-F003: Hardcoded MapKit Hours Limitation (severity: Needs Context)
- **Family ID:** FAM-mapkit-hours-limitation
- **Source:** self-review adjudicated (PlaceListCell.swift)
- **Root cause:** plan-fault — Limitation of Apple's MapKit API regarding business hours, preventing dynamic mapping without an external provider.
- **Evidence reviewed:** Chat context, `PlaceListCell.swift`.
- **Pattern/architecture impact:** Impacts the ability to deliver dynamic "Abierto / Cerrado" states using MKLocalSearch.
- **Corrected approach:** Acknowledge the MapKit limitation. Wait for explicit direction to migrate the search logic to Overpass API.
- **Disposition:** open_question
- **Routed output:** Open question

## Disposition Mapping

| Finding | Severity | Root cause | Disposition | Routed output |
|---|---|---|---|---|
| R001-F001 | Minor | dev-fault | code_increment | Increment 8 |
| R001-F002 | Minor | dev-fault | code_increment | Increment 9 |
| R001-F003 | Needs Context | plan-fault | open_question | Open question |

## Residual Risks and Open Questions
- **R001-F003 (MapKit limitations):** How should the Overpass API integration be structured to replace the `MKLocalSearch` data source for business hours? Awaiting user directions.
<!-- remediation-round:end round_id=R001 -->

<!-- remediation-round:start round_id=R002 -->
## Remediation Summary
- **Round ID:** R002
- **UTC:** 2026-08-16T21:42:00Z
- **Round type:** standard
- **Source/Predecessor:** Chat context (implementation_plan.md approval)
- **Plan cutoff increment:** 9
- **Plan SHA-256 before append:** 63bdae51d3fe85b2e6655132c4bf4d39cdefa5197ea210ad08dd5f42e51b1ada
- **Command-log correlation:** `round_id=R002`
- **Context-gap carry-forward:** none
- **Reconciles:** none
- **Recovery confidence:** not-applicable
- **Recovered mappings:** none
- **Unrecoverable gaps:** none

## Diagnosis

### Finding R002-F001: Overpass API Migration (severity: Major)
- **Family ID:** FAM-mapkit-hours-limitation
- **Source:** Chat context & implementation_plan.md
- **Root cause:** plan-fault — The architecture relied on `MKLocalSearch` which lacks dynamic opening hours.
- **Evidence reviewed:** `implementation_plan.md`, `MasterPlan.md`
- **Pattern/architecture impact:** Replaces `MKLocalSearch` dependency in the Data layer with a custom `NearbyPlacesAPIRouter` utilizing the global `APIRequestDispatcher`.
- **Corrected approach:** Implement Overpass API integration, keeping the Domain and Presentation layers mostly intact except for rendering the dynamically fetched string for opening hours.
- **Disposition:** code_increment
- **Routed output:** Increments 10, 11, 12

## Disposition Mapping

| Finding | Severity | Root cause | Disposition | Routed output |
|---|---|---|---|---|
| R002-F001 | Major | plan-fault | code_increment | Increments 10, 11, 12 |





## Residual Risks and Open Questions
<!-- remediation-round:end round_id=R002 -->

<!-- remediation-round:start round_id=R003 -->
## Remediation Summary
- **Round ID:** R003
- **UTC:** 2026-08-16T21:53:00Z
- **Round type:** standard
- **Source/Predecessor:** Chat context (answers to R002 open questions)
- **Plan cutoff increment:** 9
- **Plan SHA-256 before append:** a93581c4a28483f892af96f8633581abb39f9a91aaa66f2bd283bcd8477b41f5
- **Command-log correlation:** `round_id=R003`
- **Context-gap carry-forward:** none
- **Reconciles:** Increments 10-15
- **Recovery confidence:** not-applicable
- **Recovered mappings:** none
- **Unrecoverable gaps:** none

## Recurrence Analysis
- **Recurring Family:** FAM-mapkit-hours-limitation
- **Prior Increment(s):** Increments 10, 11, 12 (from R002)
- **Recurrence Type:** new_requirement / decomposition_fault
- **Analysis:** The user provided explicit architectural constraints (xcconfig files, AppConfiguration) and specific parsing scenarios for `opening_hours` that were not covered by the initial plan in R002. Furthermore, the R002 decomposition violated `incremental-decomposition` rules by breaking an abstraction across increments (Router created in 10, used in 11) and failing to provide verified goals.
- **Convergence:** We have collapsed and re-ordered the increments into 10, 11, 12, 13, 14 strictly adhering to the vertical slice boundary rules.

## Diagnosis

### Finding R003-F001: Hardcoded URLs in Overpass API plan (severity: Major)
- **Family ID:** FAM-mapkit-hours-limitation
- **Source:** Chat context
- **Root cause:** plan-fault — The initial plan assumed hardcoding the Overpass URL in the router, bypassing the AppConfiguration pattern.
- **Evidence reviewed:** `AppConfiguration.swift`
- **Pattern/architecture impact:** Requires adding `.xcconfig` environments and mapping `API_SCHEME` and `API_HOST` for `AppConfiguration` consumption.
- **Corrected approach:** Add Debug and Release `.xcconfig` files containing `API_SCHEME=https` and `API_HOST=overpass-api.de`.
- **Disposition:** code_increment
- **Routed output:** Increment 10

### Finding R003-F002: Missing User-Agent implementation (severity: Major)
- **Family ID:** FAM-mapkit-hours-limitation
- **Source:** Chat context
- **Root cause:** plan-fault — The initial plan failed to specify how the User-Agent should be centrally generated using AppInfo.
- **Evidence reviewed:** `APIConfiguration.swift`, `AppInfo.swift`
- **Pattern/architecture impact:** Adds the `User-Agent` header to `DefaultHTTPConfiguration` instead of locally in the router.
- **Corrected approach:** Use `AppInfo.appName` and `AppInfo.shortVersion` to format a standard User-Agent header in `APIConfiguration.swift`.
- **Disposition:** code_increment
- **Routed output:** Increment 11

### Finding R003-F003: Missing opening hours parsing constraint (severity: Major)
- **Family ID:** FAM-mapkit-hours-limitation
- **Source:** Chat context
- **Root cause:** plan-fault — The initial plan assumed showing the raw OSM opening hours string. The user requires parsing 5 specific scenarios into a boolean representation, falling back to nil.
- **Evidence reviewed:** Chat context
- **Pattern/architecture impact:** Requires a dedicated parser utility in the Domain/Data layer to interpret OSM `opening_hours`.
- **Corrected approach:** Create `OSMOpeningHoursParser` to handle the specific scenarios and map to `Bool?`.
- **Disposition:** code_increment
- **Routed output:** Increment 12

### Finding R003-F004: Incremental Decomposition Violations in R002 (severity: Major)
- **Family ID:** FAM-mapkit-hours-limitation
- **Source:** Chat context / SKILL.md
- **Root cause:** plan-fault — The R002 increments failed to structure verifiable goals, failed to provide explicit `None — <reason>` values in impact lists, and cut mid-abstraction (Router created in 10, consumed in 11).
- **Evidence reviewed:** `.agents/skills/incremental-decomposition/SKILL.md`
- **Pattern/architecture impact:** Re-structure the network refactor into a single vertical slice "Migrate NearbyPlacesService to Overpass API".
- **Corrected approach:** Consolidate network execution into Increment 13. Map UI state in Increment 14.
- **Disposition:** code_increment
- **Routed output:** Increments 13, 14

## Disposition Mapping

| Finding | Severity | Root cause | Disposition | Routed output |
|---|---|---|---|---|
| R003-F001 | Major | plan-fault | code_increment | Increment 10 |
| R003-F002 | Major | plan-fault | code_increment | Increment 11 |
| R003-F003 | Major | plan-fault | code_increment | Increment 12 |
| R003-F004 | Major | plan-fault | code_increment | Increments 13, 14 |



## Residual Risks and Open Questions
<!-- remediation-round:end round_id=R003 -->
