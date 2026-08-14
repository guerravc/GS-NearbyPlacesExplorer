# Practical Guide — Style Guide

This document covers day-to-day practices for UI development, performance, security, testing, and process within **GS-NearbyPlacesExplorer**.

## 🎨 UI & Design System

The application relies entirely on SwiftUI. Since there is no external corporate UI library (e.g., RDSUI), all UI components should be built using native Apple paradigms.

- **Componentization:** Break down large Views into smaller, reusable subviews located in `DesignSystem/Components`.
- **Styling:** Use `DesignSystem/Foundation` for centralized Typography and Color extensions to maintain a cohesive look and feel.
- **Modifiers:** Prefer `.foregroundStyle(...)` over the deprecated `.foregroundColor`.
- **Adaptability:** Ensure all custom components support Dark Mode and Dynamic Type natively.
- **Map Integration:** Use native `MapKit` in SwiftUI (`Map` view introduced in iOS 17) for displaying places.

## ⚡ Performance

- **Async APIs:** Do not block the Main Thread. Use `@MainActor` for ViewModels and offload heavy computation or blocking operations (if strictly required) to background Tasks.
- **Lazy Loading:** Use `LazyVStack` or `LazyVGrid` for scrolling lists of nearby places to ensure memory efficiency.
- **Images:** Cache network images appropriately. If using `AsyncImage`, be aware of its lack of native caching, and consider a custom cache wrapper if performance degrades.

## 🔒 Security

- **Tokens & Credentials:** The Google Sign-In SDK session tokens and any API Keys MUST be stored securely using iOS **Keychain Services**. Do not store sensitive tokens in `UserDefaults`.
- **UserDefaults:** Strictly limit `UserDefaults` to non-sensitive data, such as the user's saved Favorite Places IDs or UI preferences.
- **Location Data:** Location tracking is a sensitive permission. Request `When In Use` authorization only when the user explicitly reaches the map or nearby places feature, and handle denial states gracefully.

## 🧪 Testing

- **Frameworks:** Use `XCTest` or the new `Swift Testing` macro framework (`@Test`).
- **Scope:** 
  - Unit test `UseCases` by mocking the `APIClient` or `Repositories`.
  - Unit test `ViewModels` by injecting mocked `UseCases` into their initializers.
- **Naming:** Follow the `test_whenCondition_expectOutcome` naming convention to clearly express the intent of the test.

---
**See also:**
- [Main Style Guide Index](STYLEGUIDE.md)
