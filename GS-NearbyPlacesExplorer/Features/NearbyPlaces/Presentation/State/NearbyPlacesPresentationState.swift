import MapKit
import Observation
import SwiftUI

@MainActor
@Observable
final class NearbyPlacesPresentationState {
  var mapPosition: MapCameraPosition = .region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
  var selectedPlace: NearbyPlacesEntity?
  var showsUserLocation = false
  var listScrollAnchorID: NearbyPlacesEntity.ID?
}
