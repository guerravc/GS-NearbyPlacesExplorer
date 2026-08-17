// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
//
//  AboutThePlaceViewModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation



/// View model for the AboutThePlace screen.
///
/// Orchestrates the initial data load (place details + favorite status),
/// handles the optimistic toggle of the favorite state, and exposes
/// error feedback to the view. Runs exclusively on the main actor.
@MainActor
@Observable
public final class AboutThePlaceViewModel {
    /// Whether an initial or retry load is in progress.
    public private(set) var isLoading: Bool = false
    /// Controls presentation of the error alert.
    public var showError: Bool = false
    /// Localized error message shown in the alert when `showError` is `true`.
    public var errorMessage: String? = nil

    /// Fully loaded place details model. `nil` while loading or on error.
    public private(set) var placeDetails: AboutThePlaceDetailModel? = nil
    /// Whether the current user has marked this place as a favorite.
    public private(set) var isFavorite: Bool = false
    
    @ObservationIgnored
    @Inject var fetchPlaceDetailsUC: any FetchPlaceDetailsUC
    
    @ObservationIgnored
    @Inject var checkFavoriteStatusUC: any CheckFavoriteStatusUC
    
    @ObservationIgnored
    @Inject var toggleFavoritePlaceUC: any ToggleFavoritePlaceUC
    
    @ObservationIgnored
    @Inject var restoreSignInUC: any RestoreSignInUC
    
    public init() {}
    
    private var userEmail: String? = nil
    
    /// Loads place details and favorite status concurrently when the view appears.
    ///
    /// The user session is restored first to obtain the authenticated email.
    /// Both the details fetch and the favorite status check are then run in parallel.
    ///
    /// - Parameter osmId: The OSM element ID of the place to display.
    public func onAppear(osmId: Int) async {
        isLoading = true
        showError = false
        
        let sessionResult = await restoreSignInUC.execute()
        if case .success(let profile) = sessionResult {
            self.userEmail = profile.email
        }
        
        async let fetchDetailsTask = fetchPlaceDetailsUC.execute(osmId)
        
        // We only check favorite status if we have a user email
        let checkFavoriteTask: () async -> Result<Bool, Error> = {
            if let email = self.userEmail {
                return await self.checkFavoriteStatusUC.execute(CheckFavoriteStatusInput(osmId: osmId, userEmail: email))
            } else {
                return .failure(NSError(domain: "Auth", code: -1, userInfo: nil))
            }
        }
        
        let detailsResult = await fetchDetailsTask
        let favoriteResult = await checkFavoriteTask()
        
        switch detailsResult {
        case .success(let entity):
            let model = AboutThePlaceDetailModel(entity: entity)
            self.placeDetails = model
        case .failure(let error):
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
        
        switch favoriteResult {
        case .success(let isFav):
            self.isFavorite = isFav
        case .failure:
            self.isFavorite = false
        }
        
        isLoading = false
    }
    
    /// Toggles the favorite state of the currently displayed place.
    ///
    /// Applies an optimistic update immediately so the UI responds without waiting
    /// for the persistence layer. If the operation fails, the state is reverted.
    public func toggleFavorite() {
        guard let model = placeDetails, let email = userEmail else { return }
        
        let newFavStatus = !isFavorite
        self.isFavorite = newFavStatus
        
        Task {
            let entity = FavoritePlaceEntity(userEmail: email, osmId: model.osmId, name: model.name)
            let result = await toggleFavoritePlaceUC.execute(entity)
            if case .failure = result {
                // Revert on failure
                self.isFavorite = !newFavStatus
            }
        }
    }
}
