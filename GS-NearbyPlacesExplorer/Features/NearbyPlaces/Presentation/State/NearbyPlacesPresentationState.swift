// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import MapKit
import Observation
import SwiftUI

/// Holds transient UI state for the NearbyPlaces screen that is shared between
/// the map and list tabs but does not belong in the ViewModel.
///
/// Separating this state from ``NearbyPlacesViewModel`` keeps the ViewModel
/// focused on business logic while this type owns pure presentation concerns
/// (camera position, scroll position, selection, etc.).
@MainActor
@Observable
final class NearbyPlacesPresentationState {
  /// Current camera position displayed on the map. Defaults to Mexico City.
  var mapPosition: MapCameraPosition = .region(
    MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
  /// The place currently selected by the user (via map pin or list tap).
  var selectedPlace: NearbyPlacesEntity?
  /// Whether the map should display the blue user-location dot.
  var showsUserLocation = false
  /// The ID of the list item used as the scroll anchor when switching tabs.
  var listScrollAnchorID: NearbyPlacesEntity.ID?
}
