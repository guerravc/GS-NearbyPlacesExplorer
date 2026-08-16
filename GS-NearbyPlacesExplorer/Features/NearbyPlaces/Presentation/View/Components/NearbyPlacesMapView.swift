import SwiftUI
import MapKit

public struct NearbyPlacesMapView: View {
    public let places: [NearbyPlacesEntity]
    @Binding public var position: MapCameraPosition
    @Binding public var selectedPlace: NearbyPlacesEntity?
    public let showsUserLocation: Bool
    public let onPlaceSelected: (NearbyPlacesEntity) -> Void
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
        NearbyPlacesEntity(id: "1", name: "Café", coordinate: (19.43, -99.13), category: "MKPOICategoryCafe", address: nil)
    ]
    NearbyPlacesMapView(
        places: places,
        position: $position,
        selectedPlace: .constant(nil),
        onRecenterTapped: {}
    )
}
