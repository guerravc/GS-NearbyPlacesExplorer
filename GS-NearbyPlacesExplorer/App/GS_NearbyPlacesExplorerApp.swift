// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
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
    @Provider var dispatcher: APIRequestDispatching = APIRequestDispatcher()
    
    @Provider var aboutThePlaceLocalDataSource: AboutThePlaceLocalDataSource = DefaultAboutThePlaceStorage()
    @Provider var aboutThePlaceRemoteDataSource: AboutThePlaceRemoteDataSource = DefaultAboutThePlaceService()
    @Provider var aboutThePlaceGateway: AboutThePlaceGateway = DefaultAboutThePlaceRepository()
    @Provider var fetchPlaceDetailsUC: any FetchPlaceDetailsUC = FetchPlaceDetailsUCImpl()
    
    @Provider var favoritePlacesGateway: FavoritePlacesGateway = DefaultFavoritePlacesRepository()
    @Provider var favoritePlacesLocalDataSource: FavoritePlacesLocalDataSource = DefaultFavoritePlacesStorage()
    @Provider var checkFavoriteStatusUC: any CheckFavoriteStatusUC = CheckFavoriteStatusUCImpl()
    @Provider var toggleFavoritePlaceUC: any ToggleFavoritePlaceUC = ToggleFavoritePlaceUCImpl()
    
    /// Shared SwiftUI state for the selected root flow and navigation stack.
    @State private var router = AppRouter()
    @State private var loginViewModel: LoginViewModel
    
    /// Configures the app router and wires the cross-module logout closure.
    ///
    /// The `performLogout` closure clears the stored token and resets the navigation
    /// stack to the login root, ensuring no authenticated state leaks across sessions.
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
    
    /// Shared SwiftData `ModelContainer` for on-device persistence.
    ///
    /// Registered schema includes ``FavoritePlace``. The container is created once
    /// as a static property to avoid reinitialising SwiftData on every App body evaluation.
    static let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FavoritePlace.self,
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
        .modelContainer(Self.sharedModelContainer)
    }
}
