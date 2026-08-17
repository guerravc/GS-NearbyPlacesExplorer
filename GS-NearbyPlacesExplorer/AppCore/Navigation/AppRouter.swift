// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import SwiftUI
import Observation

/// Represents the main root flows of the application.
enum AppRoot: Equatable {
    /// The unauthenticated login flow.
    case login
    /// The authenticated main application flow.
    case main
}

/// Represents the navigation destinations within the app.
enum Destination: Hashable {
    /// The Nearby Places explorer view.
    case nearbyPlaces
}

/// Global router object that manages the navigation state of the application.
@Observable
final class AppRouter {
    /// The current root flow of the app.
    var root: AppRoot = .login
    /// The navigation path stack for hierarchical navigation.
    var path = NavigationPath()
    
    /// Closure to be injected by the App composition root to perform cross-module logout
    public var performLogout: (() -> Void)? = nil
}
