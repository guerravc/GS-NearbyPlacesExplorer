import CoreLocation
import MapKit
import SwiftUI

/// Root SwiftUI view for the NearbyPlaces module.
public struct NearbyPlacesView: View {

  @Environment(AppRouter.self) private var router
  @State private var viewModel: NearbyPlacesViewModel
  @State private var locationManager = LocationManager()

  @State private var selectedTab: Tabs = .map
  @State private var lastContentTab: Tabs = .map
  @State private var isSearchPresented = false
  @State private var presentationState = NearbyPlacesPresentationState()
  @State private var navigationPath: [NearbyPlacesEntity] = []

  enum Tabs: Hashable {
    case map
    case list
    case search
  }

  public init(viewModel: NearbyPlacesViewModel) {
    self._viewModel = State(initialValue: viewModel)
  }

  public var body: some View {
    @Bindable var bindableViewModel = viewModel

    TabView(selection: $selectedTab) {
      Tab("Mapa", systemImage: "map.fill", value: .map) {
        tabContent(for: .map, title: "Mapa")
      }

      Tab("Lista", systemImage: "list.bullet", value: .list) {
        tabContent(for: .list, title: viewModel.title)
      }

      Tab(value: .search, role: .search) {
        searchTabContent
      }
    }
    .tabViewStyle(.sidebarAdaptable)
    .alert("Error al buscar lugares", isPresented: $bindableViewModel.showError) {
      Button("Reintentar") {
        viewModel.retryLastSearch()
      }
      Button("Cerrar", role: .cancel) { }
    } message: {
      Text(viewModel.errorMessage ?? "No fue posible completar la búsqueda.")
    }
    .onChange(of: selectedTab) { _, tab in
      switch tab {
      case .map, .list:
        lastContentTab = tab
        isSearchPresented = false
      case .search:
        isSearchPresented = true
      }
    }
    .onChange(of: locationManager.location) { oldLocation, newLocation in
      if let newLocation {
        if let oldSpan = presentationState.mapPosition.region?.span {
          presentationState.mapPosition = .region(
            MKCoordinateRegion(
              center: newLocation.coordinate,
              span: oldSpan
            ))
        } else {
          presentationState.mapPosition = .region(
            MKCoordinateRegion(
              center: newLocation.coordinate,
              span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            ))
        }
        if oldLocation == nil {
          scheduleSearch()
        }
      }
    }
    .onAppear {
      if locationManager.isAuthorized {
        locationManager.requestLocation()
      } else {
        locationManager.requestAuthorization()
      }
    }
  }

  private func tabContent(for tab: Tabs, title: String) -> some View {
    NavigationStack(path: $navigationPath) {
      contentFor(
        isMap: tab == .search ? lastContentTab == .map : tab == .map,
        activeTab: tab
      )
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { logoutToolbar }
    }
  }

  private var searchTabContent: some View {
    tabContent(for: .search, title: "Buscar")
      .searchable(
        text: $viewModel.query,
        isPresented: $isSearchPresented,
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Buscar lugares cercanos"
      )
      .searchPresentationToolbarBehavior(.avoidHidingContent)
      .onSubmit(of: .search) {
        submitSearch()
      }
      .onChange(of: viewModel.query) { _, _ in
        scheduleSearch()
      }
      .onAppear {
        isSearchPresented = true
      }
  }

  @ToolbarContentBuilder
  private var logoutToolbar: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: {
        router.performLogout?()
      }) {
        Image(systemName: "rectangle.portrait.and.arrow.right")
      }
      .tint(.red)
    }
  }

  @ViewBuilder
  private func contentFor(isMap: Bool, activeTab: Tabs) -> some View {
    ZStack {
      if locationManager.isDenied {
        locationDeniedView
      } else {
        Group {
          switch viewModel.state {
          case .idle:
            if isMap {
              mapView(items: [], activeTab: activeTab)
            } else {
              Color.clear
            }
          case .loaded(let items):
            if isMap {
              mapView(items: items, activeTab: activeTab)
            } else {
              listView(items: items)
            }
          case .empty(let message):
            if isMap {
              mapView(items: [], activeTab: activeTab)
            } else {
              emptyView(message: message)
            }
          }
        }
      }
    }
    .ignoresSafeArea(edges: .bottom)
    .navigationDestination(for: NearbyPlacesEntity.self) { place in
      AboutThePlaceView(placeId: place.id, placeName: place.name)
        .toolbar(.hidden, for: .tabBar)
    }
  }

  private func mapView(items: [NearbyPlacesEntity], activeTab: Tabs) -> some View {
    @Bindable var presentationState = presentationState

    return NearbyPlacesMapView(
      places: items,
      position: $presentationState.mapPosition,
      selectedPlace: $presentationState.selectedPlace,
      showsUserLocation: presentationState.showsUserLocation,
      onPlaceSelected: { place in
        guard selectedTab == activeTab else { return }
        navigationPath.append(place)
        presentationState.selectedPlace = nil
      }
    ) {
      presentationState.showsUserLocation = true

      guard let location = locationManager.location else { return }

      withAnimation {
        presentationState.mapPosition = .region(
          MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
          ))
      }
    }
  }

  private func listView(items: [NearbyPlacesEntity]) -> some View {
    @Bindable var presentationState = presentationState

    return NearbyPlacesListView(
      places: itemsSortedByDistance(items),
      currentLocation: locationManager.location,
      selectedPlace: $presentationState.selectedPlace,
      initialScrollAnchorID: presentationState.listScrollAnchorID
    ) { scrollAnchorID in
      presentationState.listScrollAnchorID = scrollAnchorID
    }
  }

  private func itemsSortedByDistance(_ items: [NearbyPlacesEntity]) -> [NearbyPlacesEntity] {
    guard let currentLocation = locationManager.location else { return items }

    return items.enumerated()
      .sorted { left, right in
        let leftDistance = currentLocation.distance(
          from: CLLocation(
            latitude: left.element.coordinate.latitude,
            longitude: left.element.coordinate.longitude
          )
        )
        let rightDistance = currentLocation.distance(
          from: CLLocation(
            latitude: right.element.coordinate.latitude,
            longitude: right.element.coordinate.longitude
          )
        )
        return leftDistance == rightDistance ? left.offset < right.offset : leftDistance < rightDistance
      }
      .map(\.element)
  }

  private var locationDeniedView: some View {
    VStack(spacing: 16) {
      Image(systemName: "location.slash.fill")
        .font(.system(size: 50))
        .foregroundColor(.red)
      Text("Ubicación necesaria")
        .font(.title2).bold()
      Text(
        "Esta funcionalidad requiere acceso a tu ubicación. Por favor, habilítala en Configuración."
      )
      .multilineTextAlignment(.center)
      .padding(.horizontal)
      Button("Abrir Configuración") {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          UIApplication.shared.open(url)
        }
      }
      .buttonStyle(.borderedProminent)
    }
  }

  private func emptyView(message: String) -> some View {
    VStack(spacing: 16) {
      ZStack {
        RoundedRectangle(cornerRadius: 32)
          .fill(Color.blue.opacity(0.15))
          .frame(width: 120, height: 120)

        Image(systemName: "magnifyingglass")
          .font(.system(size: 50, weight: .medium))
          .foregroundStyle(.blue)
          .offset(x: -8, y: -8)

        Image(systemName: "xmark.circle.fill")
          .font(.system(size: 28, weight: .medium))
          .foregroundStyle(.blue)
          .background(Circle().fill(.white))
          .offset(x: 24, y: 24)
      }

      Text("Sin resultados")
        .font(.title3.weight(.bold))

      Text(message)
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 32)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(.systemBackground))
  }

  private func scheduleSearch() {
    let lat = locationManager.location?.coordinate.latitude ?? 19.4326
    let lng = locationManager.location?.coordinate.longitude ?? -99.1332
    viewModel.scheduleSearch(latitude: lat, longitude: lng)
  }

  private func submitSearch() {
    let lat = locationManager.location?.coordinate.latitude ?? 19.4326
    let lng = locationManager.location?.coordinate.longitude ?? -99.1332
    viewModel.submitSearch(latitude: lat, longitude: lng)
  }
}

#Preview("Idle") {
  let mockUC = MockFetchNearbyPlacesUC()
  let vm = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
  NearbyPlacesView(viewModel: vm)
    .environment(AppRouter())
}

#Preview("Loaded Map") {
  let mockUC = MockFetchNearbyPlacesUC()
  let vm = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
  vm.state = .loaded([
    NearbyPlacesEntity(
      id: "1", name: "El Buen Café", coordinate: (19.43, -99.13), category: "cafe",
      address: "Calle 1"),
    NearbyPlacesEntity(
      id: "2", name: "Restaurante Central", coordinate: (19.44, -99.14), category: "restaurant",
      address: "Avenida 2")
  ])
  return NearbyPlacesView(viewModel: vm)
    .environment(AppRouter())
}

#Preview("Empty State") {
  let mockUC = MockFetchNearbyPlacesUC()
  let vm = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
  vm.state = .empty("No encontramos resultados para 'Tu búsqueda'. Intenta con otra búsqueda.")
  return NearbyPlacesView(viewModel: vm)
    .environment(AppRouter())
}

#Preview("Error State") {
  let mockUC = MockFetchNearbyPlacesUC()
  let vm = NearbyPlacesViewModel(fetchNearbyPlacesUC: mockUC)
  vm.errorMessage = "Hubo un problema al buscar lugares. Revisa tu conexión a internet e intenta de nuevo."
  vm.showError = true
  return NearbyPlacesView(viewModel: vm)
    .environment(AppRouter())
}

private class MockFetchNearbyPlacesUC: FetchNearbyPlacesUC {
  func execute(_ input: FetchNearbyPlacesInput) async -> Result<[NearbyPlacesEntity], Error> {
    return .success([])
  }
}
