//
//  GS_NearbyPlacesExplorerApp.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Lopez on 13/08/26.
//

import SwiftUI
import SwiftData

/// The main entry point of the GS-NearbyPlacesExplorer application.
@main
struct GS_NearbyPlacesExplorerApp: App {
    @Provider var localDataSource: LoginLocalDataSource = LoginStorage()
    @Provider var remoteDataSource: LoginRemoteDataSource = LoginService()
    @Provider var loginGateway: LoginGateway = DefaultLoginRepository()
    @Provider var signInUC: any SignInUC = SignInUCImpl()
    @Provider var restoreSignInUC: any RestoreSignInUC = RestoreSignInUCImpl()
    
    @State private var router = AppRouter()
    @State private var loginViewModel: LoginViewModel
    
    init() {
        let initialRouter = AppRouter()
        self._router = State(initialValue: initialRouter)
        self._loginViewModel = State(initialValue: LoginViewModel(router: initialRouter))
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                switch router.root {
                case .login:
                    LoginView(viewModel: loginViewModel)
                case .main:
                    NavigationStack(path: $router.path) {
                        Text("Nearby Places View") // Placeholder
                            .navigationDestination(for: Destination.self) { destination in
                                switch destination {
                                case .nearbyPlaces:
                                    Text("Nearby Places Detail")
                                }
                            }
                    }
                }
            }
            .animation(.easeInOut, value: router.root)
            .environment(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
