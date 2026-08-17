## Design Specification

- **Reference material:** Screenshot/mockup attached in the chat context.

### 1. Typography & Colors
- **Background Color:** Solid white (`Color.white`).
- **Primary Text Color (Titles):** Black (`Color.primary`).
- **Secondary Text Color (Subtitles):** Gray (`Color.secondary` or `#8E8E93`).
- **App Theme Blue (Icon/Transitory Text):** Dark Blue (e.g., `#0A3161` or a custom `Color("BrandBlue")` if present, RGB `~10, 49, 97`).
- **Logo Background Blue:** Light pastel blue (e.g., `#D3E3FD`, RGB `~211, 227, 253`).
- **Fonts:** System fonts.
  - Title: `.title2` or `.title`, `.fontWeight(.semibold)`.
  - Subtitle: `.callout` or `.body`, `.fontWeight(.regular)`.
  - Footer: `.footnote`, `.fontWeight(.regular)`.

### 2. LoginView Elements & Layout
- **App Logo / Icon:**
  - Positioned top-center.
  - Background shape: `RoundedRectangle(cornerRadius: 24)` filled with Light pastel blue.
  - Icon: SF Symbol `map` (or `map.fill`) layered with `mappin.circle.fill`. Alternatively, `map.circle.fill`. Rendered in Dark Blue.
  - Approximate size: Frame `120x120`.
- **Title:**
  - Exact text: "Explorador de lugares".
  - Centered below the logo.
- **Subtitle:**
  - Exact text: "Descubre puntos de interes cerca de ti".
  - Centered below the title, colored gray.
- **"Continuar con Google" Button:**
  - Exact text: "Continuar con Google".
  - Icon: Use an asset "GoogleLogo" if available. If no asset exists, fallback to an SF Symbol like `g.circle.fill` or `globe` as a placeholder, but a custom image asset is preferred.
  - Background: White (`Color.white`).
  - Border: Thin gray/black border (`RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4), lineWidth: 1)`).
  - Text color: Black.
  - Dimensions: Full width with `.padding(.horizontal, 24)`, height ~`50`.
- **Footer Text:**
  - Exact text: "Al continuar aceptas los terminos y el uso de tu ubicacion".
  - Bottom aligned, colored light gray.

### 3. LoginTransitoryView Elements
- **Background:** White (`Color.white`).
- **Profile Image:**
  - `AsyncImage` loading the user's Google profile URL.
  - Shape: `.clipShape(Circle())`.
  - Fallback/Placeholder if nil: SF Symbol `person.crop.circle.fill` in gray.
  - Dimensions: Frame `100x100`.
- **User Name:**
  - Text: The user's name returned from Google Auth.
  - Font: `.title2`, `.fontWeight(.semibold)`.
  - Color: App Theme Dark Blue (same as the map icon).
  - Centered below the profile image.

### 4. Interactions & Flow
- **Loading state:** The "Continuar con Google" button becomes disabled and its text/icon is replaced by a native `ProgressView`. This is controlled by an `isLoading` flag in the ViewModel. Upon completion (success, error, or user cancellation), the flag resets to `false`.
- **Success state:** `LoginView` cross-fades into `LoginTransitoryView` using `.transition(.opacity.animation(.easeInOut))`.
- **Transition:** `LoginTransitoryView` is displayed for exactly 2 seconds. The `LoginViewModel` then calls `AppRouter` to push `NearbyPlacesView` onto the `NavigationPath`.

### 5. Alerts
- **Network error:** Native iOS `.alert` with the exact text "Error de red. Inténtalo de nuevo." and a single "OK" button.
