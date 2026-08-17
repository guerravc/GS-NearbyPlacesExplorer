// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import SwiftUI
import MapKit

/// SwiftUI view that renders a MapKit map populated with nearby place annotations.
///
/// Handles camera position sync, tap-to-select annotations, and exposes
/// a re-center button so the user can return to their current location.
public struct NearbyPlacesMapView: View {
    /// List of places to render as annotations on the map.
    public let places: [NearbyPlacesEntity]
    /// Current camera position, updated by the map when the user pans or zooms.
    @Binding public var position: MapCameraPosition
    /// The currently selected place, updated when the user taps an annotation.
    @Binding public var selectedPlace: NearbyPlacesEntity?
    /// When `true`, the blue user-location dot is displayed on the map.
    public let showsUserLocation: Bool
    /// Called with the tapped place whenever the user selects an annotation.
    public let onPlaceSelected: (NearbyPlacesEntity) -> Void
    /// Called when the user taps the re-center button.
    public let onRecenterTapped: () -> Void
    
    public init(
        places: [NearbyPlacesEntity],
        position: Binding<MapCameraPosition>,
        selectedPlace: Binding<NearbyPlacesEntity?>,
        showsUserLocation: Bool = false,
        onPlaceSelected: @escaping (NearbyPlacesEntity) -> Void = { _ in },
        onRecenterTapped: @escaping () -> Void
    ) {
        self.places = places
        self._position = position
        self._selectedPlace = selectedPlace
        self.showsUserLocation = showsUserLocation
        self.onPlaceSelected = onPlaceSelected
        self.onRecenterTapped = onRecenterTapped
    }
    
    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position, selection: $selectedPlace) {
                if showsUserLocation {
                    UserAnnotation()
                }

                ForEach(places, id: \.id) { place in
                    Annotation(place.name, coordinate: CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)) {
                        Image(systemName: POICategoryMapper.map(category: place.category))
                            .foregroundColor(.red)
                            .padding(8)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .tag(place)
                }
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                position = .camera(context.camera)
            }
            .onChange(of: selectedPlace) { _, place in
                guard let place else { return }
                onPlaceSelected(place)
            }
            .ignoresSafeArea(edges: .top)
            
            Button(action: onRecenterTapped) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 4)
            }
            .padding()
            .padding(.bottom, 90)
        }
    }
}

#Preview("NearbyPlacesMapView") {
    @Previewable @State var position: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.43, longitude: -99.13),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    let places = [
        NearbyPlacesEntity(id: "1", name: "Café", coordinate: (19.43, -99.13), category: "cafe", address: nil)
    ]
    NearbyPlacesMapView(
        places: places,
        position: $position,
        selectedPlace: .constant(nil),
        onRecenterTapped: {}
    )
}
