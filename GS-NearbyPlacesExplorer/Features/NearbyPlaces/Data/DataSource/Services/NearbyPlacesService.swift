import Foundation
import MapKit

public final class NearbyPlacesService: NearbyPlacesRemoteDataSource {
    public init() {}
    
    public func search(latitude: Double, longitude: Double, query: String?) async throws -> [NearbyPlacesModel] {
        let request = MKLocalSearch.Request()
        
        if let query = query, !query.isEmpty {
            request.naturalLanguageQuery = query
        } else {
            request.pointOfInterestFilter = .includingAll
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), span: span)
        request.region = region
        
        let search = MKLocalSearch(request: request)
        let response = try await search.start()
        
        return response.mapItems.compactMap { item in
            let location = item.location
            let address = item.addressRepresentations?.fullAddress(
                includingRegion: false,
                singleLine: true
            )
            return NearbyPlacesModel(
                id: item.identifier.map { String(describing: $0) } ?? UUID().uuidString,
                name: item.name,
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                pointOfInterestCategory: item.pointOfInterestCategory?.rawValue,
                title: address
            )
        }
    }
}
