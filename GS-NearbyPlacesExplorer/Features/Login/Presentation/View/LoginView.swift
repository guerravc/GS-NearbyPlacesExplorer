import SwiftUI

/// The primary presentation view for authentication.
///
/// Displays the login interface and handles user interaction for signing in
/// via the Google Sign In SDK. Provides visual feedback for loading and error states.
struct LoginView: View {
    @State private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        @Bindable var bindableViewModel = viewModel
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "map")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.blue)
                        .offset(x: -5, y: -5)
                    
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .offset(x: 15, y: 15)
                }
                .padding(.bottom, 32)
                
                // Title
                Text("Explorador de\nlugares")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)
                
                // Subtitle
                Text("Descubre puntos de interes\ncerca de ti")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 60)
                
                // Button
                Button(action: {
                    Task {
                        // Extract root view controller from current window scene
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                              let rootVC = windowScene.windows.first?.rootViewController else { return }
                        
                        await viewModel.signIn(presentingViewController: rootVC)
                    }
                }) {
                    HStack(spacing: 16) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(width: 24, height: 24)
                        } else {
                            Image(systemName: "g.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                        }
                        
                        Text("Continuar con\nGoogle")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
                    .foregroundColor(.primary)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .disabled(viewModel.isLoading)
                
                // Footer
                Text("Al continuar aceptas los terminos\ny el uso de tu ubicacion")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .opacity(viewModel.isAuthenticated ? 0 : 1)
            
            if viewModel.isAuthenticated {
                LoginTransitoryView(profile: viewModel.userProfile)
                    .transition(.opacity.animation(.easeInOut))
            }
        }
        .animation(.easeInOut, value: viewModel.isLoading)
        .animation(.easeInOut, value: viewModel.isAuthenticated)
        .alert("Error de inicio de sesión", isPresented: $bindableViewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "Ocurrió un error desconocido.")
        }
        .task {
            await viewModel.checkExistingSession()
        }
    }
}

#if DEBUG
struct MockSignInUC: SignInUC {
    func execute(_ input: Any) async -> Result<LoginEntity, Error> {
        return .failure(AuthError.unknown)
    }
}

struct MockRestoreSignInUC: RestoreSignInUC {
    func execute() async -> Result<LoginEntity, Error> {
        return .failure(AuthError.unknown)
    }
}

#Preview("Login - Default") {
    DependencyContainer.registerSingleton((any SignInUC).self, MockSignInUC())
    DependencyContainer.registerSingleton((any RestoreSignInUC).self, MockRestoreSignInUC())
    let vm = LoginViewModel(router: AppRouter())
    return LoginView(viewModel: vm)
}

#Preview("Login - Loading") {
    DependencyContainer.registerSingleton((any SignInUC).self, MockSignInUC())
    DependencyContainer.registerSingleton((any RestoreSignInUC).self, MockRestoreSignInUC())
    let vm = LoginViewModel(router: AppRouter())
    vm.isLoading = true
    return LoginView(viewModel: vm)
}

#Preview("Login - Error") {
    DependencyContainer.registerSingleton((any SignInUC).self, MockSignInUC())
    DependencyContainer.registerSingleton((any RestoreSignInUC).self, MockRestoreSignInUC())
    let vm = LoginViewModel(router: AppRouter())
    vm.errorMessage = "Error de red. Inténtalo de nuevo."
    vm.showError = true
    return LoginView(viewModel: vm)
}
#endif
