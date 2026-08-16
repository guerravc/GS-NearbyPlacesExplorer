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
    @Provider var hasStoredSessionUC: any HasStoredSessionUC = HasStoredSessionUCImpl()
    @Provider var restoreSignInUC: any RestoreSignInUC = RestoreSignInUCImpl()
    
    @Provider var nearbyPlacesService: NearbyPlacesRemoteDataSource = NearbyPlacesService()
    @Provider var nearbyPlacesGateway: NearbyPlacesGateway = NearbyPlacesRepository()
    @Provider var fetchNearbyPlacesUC: any FetchNearbyPlacesUC = FetchNearbyPlacesUCImpl()
    
    @State private var router = AppRouter()
    @State private var loginViewModel: LoginViewModel
    
    init() {
        let initialRouter = AppRouter()
        self._router = State(initialValue: initialRouter)
        self._loginViewModel = State(initialValue: LoginViewModel(router: initialRouter))
        
        // Define cross-module logout boundary
        initialRouter.performLogout = {
            let storage = LoginStorage()
            try? storage.deleteToken()
            
            Task { @MainActor in
                initialRouter.path = NavigationPath()
                initialRouter.root = .login
            }
        }
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
                    NearbyPlacesView(viewModel: NearbyPlacesViewModel())
                }
            }
            .animation(.easeInOut, value: router.root)
            .environment(router)
        }
        .modelContainer(sharedModelContainer)
    }
}
