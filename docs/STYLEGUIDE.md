# iOS Style Guide — GS-NearbyPlacesExplorer

This is the comprehensive style guide for the **GS-NearbyPlacesExplorer** iOS application. It defines the core conventions, architecture, and coding standards used across the repository. 

Whenever you contribute to this codebase, whether as a human developer or an AI assistant, you **must adhere to these rules** to ensure maintainability, testability, and a cohesive architecture.

## 📑 Contents

1. [Architecture & MVVM](STYLEGUIDE-ARCHITECTURE.md)
   Clean Architecture boundaries, SwiftUI State Management, and ViewModel patterns.
   
2. [Code Style & Swift 6](STYLEGUIDE-CODE-STYLE.md)
   Clean Code principles, naming conventions, and Swift 6 Strict Concurrency rules.
   
3. [Dependency Injection](STYLEGUIDE-DI.md)
   Rules for using the native `DependencyContainer`, registering services, and resolving dependencies safely.

4. [Networking](STYLEGUIDE-NETWORKING.md)
   Standardized usage of `APIRouter`, `APIRequestDispatcher`, and `APIClient` for both HTTP and SSE streams.

5. [Logging](STYLEGUIDE-LOGGING.md)
   Native OSLog integration (`Log.swift`), privacy categorization, and pointer correlation.

6. [Practical Guide & UI](STYLEGUIDE-PRACTICAL.md)
   Day-to-day practices for SwiftUI composition, State, Testing, and Security.

---

> **Note to AI Agents:** When reading the repository, always refer back to these documents before proposing architectural or styling changes. Ensure new code strictly aligns with the conventions defined here.
