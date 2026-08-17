---
name: "Design Specification"
overview: "UI/UX Specifications for About The Place View"
isProject: false
task_id: feature-about-place-view
version: 1.0.0
---

## Design Specification

### Component Hierarchy
```text
NearbyPlacesView (Root/Parent)
└── NavigationStack
    └── AboutThePlaceView
        ├── Toolbar (Favorite Icon)
        ├── ZStack (Main Container)
        │   ├── ScrollView
        │   │   ├── Header (Map or Pastel Green Placeholder)
        │   │   ├── Title Section (Name, Distance)
        │   │   ├── Info HStack (Rating Box, Hours Box)
        │   │   └── Bottom Favorite Button
        │   └── Loading Overlay (Semitransparent Gray + Red Spinner)
        └── Alert (Network Error)
```

### Layout and Visual Properties
| Element | Visual Treatment |
|---|---|
| Navigation Title | `.inline` or Custom text |
| Toolbar Icon | `heart` (Gray) or `heart.fill` (Red) |
| Loading Overlay | `Color.gray.opacity(0.4)`, blocking interaction |
| Spinner Color | `.tint(.red)` |
| Idle Header Background | `#D4EBE1` (Pastel Green) |
| Idle Header Icon | `map` or `photo` in Dark Green |
| Map View (Loaded) | Height ~250-300pt, `.disabled(true)` |
| Info Boxes Container | `HStack` with equal spacing |
| Info Boxes Background | `Color.yellow.opacity(0.2)` |
| Info Boxes Corner Radius | `8pt` |
| Favorite Button (Bottom) | Large Capsule/RoundedRectangle, spans width, padded |

### Typography
| Element | Font Spec | Color |
|---|---|---|
| Place Name | `.title` or `.headline` (Bold) | `.primary` |
| Distance Label | `.subheadline` | `.secondary` |
| Info Box Content | `.subheadline` (Semibold) | `.primary` |
| Fallback Text | `.footnote` | `.secondary` |

### Visual States
1. **Idle / Loading:** Navigation executes. UI builds immediately. A full-screen or view-bounded gray overlay sits on top with a red `ProgressView`. Underneath, the header shows a pastel green block with a map icon. Text elements display "Cargando...".
2. **Success (Loaded):** The overlay fades out. The pastel green block is replaced by a `Map` centered on the target coordinate. Data populates the text fields. Info boxes display "Abierto" / Rating values.
3. **Success (Partial Data):** Same as Loaded, but missing fields (e.g., no rating) show fallback text like "N/D" or "Sin calificación" to maintain visual symmetry in the two yellow boxes.
4. **Network Error:** Overlay is removed. A native iOS `Alert` presents the standard error message used in the app, giving the user an option to retry or dismiss.
5. **Favorited State:** Tapping the heart or the bottom button triggers SwiftData write. Both icons immediately transition to `.red` and `heart.fill`. Bottom button text changes to "Desmarcar como favorito".

### Interaction Map
| User Action | UI Response | State Effect |
|---|---|---|
| View `onAppear` | Spinner appears | `isLoading = true`, Network Request dispatched |
| Tap Toolbar Heart | Icon turns red/gray | Triggers `ToggleFavoritePlaceUC` |
| Tap Bottom Button | Button turns red/gray | Triggers `ToggleFavoritePlaceUC` |
| Tap Retry on Error | Spinner appears | Re-executes `onAppear` logic |

### Fixed Copy and Localization
| Role | Copy (Spanish) |
|---|---|
| Placeholder Name | "Cargando..." |
| Placeholder Distance | "Cargando distancia..." |
| Fallback Rating | "Sin calificación" |
| Fallback Hours | "Horario no disponible" |
| Favorite Button (Not Fav) | "Marcar como favorito" |
| Favorite Button (Is Fav) | "Desmarcar como favorito" |
| Network Error Title | "Error" (Matches `NearbyPlacesView`) |
| Network Error Body | "Hubo un problema al cargar los detalles. Intenta de nuevo." |
