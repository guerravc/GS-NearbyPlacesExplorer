// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import SwiftUI
import CoreLocation

/// Vertically scrollable list of nearby place cards.
///
/// Supports synchronized scroll anchoring so that switching from the map tab
/// to the list tab scrolls the list to the last selected place.
public struct NearbyPlacesListView: View {
    /// Ordered list of places to display.
    public let places: [NearbyPlacesEntity]
    /// Current user location used to compute distance shown on each cell.
    public let currentLocation: CLLocation?
    /// The currently selected place, updated when the user taps a cell.
    @Binding public var selectedPlace: NearbyPlacesEntity?
    /// The ID of the item the list should scroll to on first appearance.
    public let initialScrollAnchorID: NearbyPlacesEntity.ID?
    /// Called whenever the visible scroll position changes, used to keep map and list in sync.
    public let onScrollAnchorChanged: (NearbyPlacesEntity.ID?) -> Void
    @State private var localScrollAnchorID: NearbyPlacesEntity.ID?
    
    public init(
        places: [NearbyPlacesEntity],
        currentLocation: CLLocation? = nil,
        selectedPlace: Binding<NearbyPlacesEntity?> = .constant(nil),
        initialScrollAnchorID: NearbyPlacesEntity.ID? = nil,
        onScrollAnchorChanged: @escaping (NearbyPlacesEntity.ID?) -> Void = { _ in }
    ) {
        self.places = places
        self.currentLocation = currentLocation
        self._selectedPlace = selectedPlace
        self.initialScrollAnchorID = initialScrollAnchorID
        self.onScrollAnchorChanged = onScrollAnchorChanged
        self._localScrollAnchorID = State(initialValue: initialScrollAnchorID)
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(places) { place in
                    NavigationLink(value: place) {
                        PlaceListCell(model: place, currentLocation: currentLocation)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                Color.white,
                                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(
                                        Color.white,
                                        lineWidth: 1
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                    .contentShape(Rectangle())
                    .simultaneousGesture(TapGesture().onEnded {
                        selectedPlace = place
                    })
                    .id(place.id)
                }
            }
            .scrollTargetLayout()
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .scrollPosition(id: $localScrollAnchorID, anchor: .top)
        .onAppear {
            localScrollAnchorID = initialScrollAnchorID
        }
        .onChange(of: localScrollAnchorID) { _, scrollAnchorID in
            onScrollAnchorChanged(scrollAnchorID)
        }
    }
}

#Preview("NearbyPlacesListView") {
    let places = [
        NearbyPlacesEntity(id: "1", name: "El Buen Café", coordinate: (19.43, -99.13), category: "cafe", address: "Calle 1"),
        NearbyPlacesEntity(id: "2", name: "Restaurante Central", coordinate: (19.44, -99.14), category: "restaurant", address: "Avenida 2")
    ]
    NearbyPlacesListView(places: places, currentLocation: nil)
}
