## Design Specification

> **Design provider was not consulted** — this specification is derived from DoR and context only and SHOULD be revisited with a design reference before implementation.

### Component Hierarchy
```text
NearbyPlacesView (Root)
├── NavigationStack
│   ├── Logout Button (Toolbar)
│   ├── searchable(text: $query)
│   ├── ProgressView Overlay (ZStack)
│   └── TabView
│       ├── NearbyPlacesMapView
│       │   └── Map
│       │       └── Marker
│       └── NearbyPlacesListView
│           └── List
│               └── NavigationLink
│                   └── PlaceListCell
```

### Layout and Visual Properties
| Element | Visual Treatment |
|---|---|
| Search Bar Placeholder | "Buscar lugares cercanos" |
| TabBar Icon (Map) | `map` |
| TabBar Icon (List) | `list.bullet` |
| Map Recenter Button | Floating `location.fill` symbol |
| Cell Background | `Color.red.opacity(0.15)` |
| Cell Corner Radius | `8` |
| Cell Icon Color | `Color.red` |
| Cell Chevron | Trailing `chevron.right` |

### Typography
| Element | Font Spec | Color |
|---|---|---|
| Cell Title | `.headline` (Bold) | `.primary` |
| Cell Subtitle | `.subheadline` | `.secondary` |

### Visual States
1. **Idle / Permission Request:** App requests location. UI is idle with empty map.
2. **Permission Denied:** "Ubicación necesaria" alert is overlaid.
3. **Searching (Loading):** Translucid overlay covers the entire screen, displaying a `ProgressView`. Search bar and tabs are blocked.
4. **Search Error:** Overlay disappears; "Error de búsqueda" alert triggers.
5. **Empty Results:** Empty state graphic displayed on list tab.
6. **Results Display:** Map shows points. List shows red cells. Subtitles compute distance and open/close state.

### Interaction Map
| User Action | UI Response | State Effect |
|---|---|---|
| Tap `onSubmit` search | Overlay appears, UI blocked | `isLoading = true`, UseCase invoked |
| Tap Map Recenter | Map region updates | `LocationManager` updates region to current coords |
| Toggle Map/List Tabs | UI switches view mode | None. ViewModel retains results array. |
| Tap PlaceListCell | `NavigationLink` triggers | Pushes `AboutThePlaceView` to navigation stack |
| Tap Logout | Clears session, resets root | Navigates to LoginView |

### Fixed Copy and Localization
| Role | Copy (Spanish) |
|---|---|
| Location Alert Title | "Ubicación necesaria" |
| Location Alert Body | "Necesitamos tu ubicación para calcular las distancias y mostrar lugares cercanos. Por favor, habilítala en las preferencias de tu dispositivo." |
| Location Alert BTN 1 | "Cancelar" |
| Location Alert BTN 2 | "Ir a Preferencias" |
| Network Error Title | "Error de búsqueda" |
| Network Error Body | "Hubo un problema al buscar lugares. Revisa tu conexión a internet e intenta de nuevo." |
| Empty State | "No encontramos resultados para '[Término]'. Intenta con otra búsqueda." |
| Status: Open | "Abierto" |
| Status: Closed | "Cerrado" |
| Status: Unknown | "Horario no disponible" |

