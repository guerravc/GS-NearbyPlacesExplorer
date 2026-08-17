import Foundation

public final class NearbyPlacesService: NearbyPlacesRemoteDataSource, @unchecked Sendable {
    @Inject var dispatcher: APIRequestDispatching
    
    public init() {}
    
    public func search(latitude: Double, longitude: Double, query: String?) async throws -> [NearbyPlacesModel] {
        let route = NearbyPlacesAPIRouter.fetchPlaces(
            latitude: latitude,
            longitude: longitude,
            radius: 2000,
            query: query
        )
        
        let result = await dispatcher.perform(route)
        
        switch result {
        case .success(let response):
            let decoder = JSONDecoder()
            do {
                let overpassResponse = try decoder.decode(OverpassResponse.self, from: response.data)
                
                return overpassResponse.elements.compactMap { element in
                    guard let latitude = element.lat ?? element.center?.lat,
                          let longitude = element.lon ?? element.center?.lon else {
                        return nil
                    }
                    let name = element.tags?.name ?? "Unknown Location"
                    let category = element.tags?.amenity ?? "unknown"
                    let openingState = OSMOpeningHoursParser.state(for: element.tags?.openingHours)
                    
                    return NearbyPlacesModel(
                        id: String(element.id),
                        name: name,
                        latitude: latitude,
                        longitude: longitude,
                        pointOfInterestCategory: category,
                        title: nil, // Overpass doesn't provide a formatted address easily in this query
                        openingState: openingState
                    )
                }
            } catch {
                throw NetworkError.decodingError(error)
            }
        case .failure(let error):
            throw error
        }
    }
}
