// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
// 
//  LoginViewModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 14/08/26.
//

import Foundation
import SwiftUI
import Observation

/// View model responsible for managing the state and actions of the Login screen.
@Observable
@MainActor
final class LoginViewModel {
    /// Indicates if a login operation is currently in progress.
    var isLoading: Bool = false
    /// Indicates if an error alert should be presented.
    var showError: Bool = false
    /// The error message to display when `showError` is true.
    var errorMessage: String? = nil
    
    /// Indicates whether the user is currently authenticated.
    var isAuthenticated: Bool = false
    /// The authenticated user's profile information.
    var userProfile: LoginEntity? = nil
    
    @ObservationIgnored @Inject var signInUC: any SignInUC
    @ObservationIgnored @Inject var hasStoredSessionUC: any HasStoredSessionUC
    @ObservationIgnored @Inject var restoreSignInUC: any RestoreSignInUC
    
    /// The router used to navigate between screens.
    private var router: AppRouter
    
    /// Initializes a new instance of `LoginViewModel`.
    /// - Parameter router: The application router.
    init(
        router: AppRouter
    ) {
        self.router = router
    }
    
    /// Initiates the sign-in process.
    /// - Parameter presentingViewController: The view controller to present the authentication UI.
    func signIn(presentingViewController: UIViewController) async {
        isLoading = true
        showError = false
        
        let result = await signInUC.execute(presentingViewController)
        
        switch result {
        case .success(let profile):
            userProfile = profile
            isAuthenticated = true
            
            // Add a small delay for UX so the user can see the spinner and transition smoothly
            try? await Task.sleep(for: .seconds(2))
            
            withAnimation {
                router.root = .main
            }
        case .failure(let error):
            handleAuthError(error)
        }
        
        isLoading = false
    }
    
    /// Checks for an existing session and restores it if available.
    func checkExistingSession() async {
        guard case .success(true) = await hasStoredSessionUC.execute() else {
            return
        }

        isLoading = true
        let result = await restoreSignInUC.execute()
        isLoading = false

        switch result {
        case .success(let profile):
            userProfile = profile
            withAnimation {
                router.root = .main
            }
        case .failure:
            // Keep the login screen idle when the stored session cannot be restored.
            break
        }
    }
    
    /// Handles authentication errors and updates the view model state.
    /// - Parameter error: The error that occurred during authentication.
    private func handleAuthError(_ error: Error) {
        if let authError = error as? AuthError {
            switch authError {
            case .userCancelled:
                // Do not show error alert when user intentionally cancels
                break
            case .networkError:
                errorMessage = "Error de red. Inténtalo de nuevo."
                showError = true
            case .unknown:
                errorMessage = "Ocurrió un error desconocido."
                showError = true
            }
        } else {
            errorMessage = "Ocurrió un error desconocido."
            showError = true
        }
    }
}
