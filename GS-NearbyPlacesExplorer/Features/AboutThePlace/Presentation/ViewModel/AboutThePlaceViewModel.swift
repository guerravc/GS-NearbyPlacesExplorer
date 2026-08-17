//
//  AboutThePlaceViewModel.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import Foundation



@MainActor
@Observable
public final class AboutThePlaceViewModel {
    public private(set) var isLoading: Bool = false
    public var showError: Bool = false
    public var errorMessage: String? = nil
    
    public private(set) var placeDetails: AboutThePlaceDetailModel? = nil
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
