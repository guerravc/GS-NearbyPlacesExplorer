//
//  AboutThePlaceView.swift
//  GS-NearbyPlacesExplorer
//
//  Created by Carlos Guerra
//

import SwiftUI
import MapKit

public struct AboutThePlaceView: View {
    let placeId: String
    let placeName: String
    
    @State private var viewModel = AboutThePlaceViewModel()
    @State private var locationManager = LocationManager()
    @Environment(\.dismiss) private var dismiss
    
    public init(placeId: String, placeName: String) {
        self.placeId = placeId
        self.placeName = placeName
    }
    
    private var distanceText: String {
        if let details = viewModel.placeDetails, let location = locationManager.location {
            let dest = CLLocation(latitude: details.coordinate.lat, longitude: details.coordinate.lon)
            let distanceMeters = location.distance(from: dest)
            let distanceKm = distanceMeters / 1000.0
            return String(format: "%.1f km desde tu ubicación", distanceKm)
        }
        return "Cargando..."
    }
    
    private var openStatusData: (text: String, color: Color) {
        guard let details = viewModel.placeDetails else { return ("Cargando...", .gray) }
        let hours = details.openingHours.lowercased()
        if hours == "24/7" {
            return ("Abierto 24/7", .green)
        } else if hours.isEmpty {
            return ("Horario no disponible", .gray)
        }
        
        // Basic pattern matching for "HH:mm-HH:mm"
        let pattern = "(\\d{2}:\\d{2})\\s*-\\s*(\\d{2}:\\d{2})"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: details.openingHours, range: NSRange(location: 0, length: details.openingHours.utf16.count)) {
            let nsString = details.openingHours as NSString
            let openTime = nsString.substring(with: match.range(at: 1))
            let closeTime = nsString.substring(with: match.range(at: 2))
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            let currentTimeString = formatter.string(from: Date())
            
            if currentTimeString >= openTime && currentTimeString < closeTime {
                return ("Abierto hasta \(closeTime)", .green)
            } else {
                return ("Cerrado. Abre \(openTime)", .red)
            }
        }
        
        return ("Horario irregular", .blue)
    }
    
    public var body: some View {
        @Bindable var bindableViewModel = viewModel
        
        ZStack {
            // Main Content
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        Text(viewModel.placeDetails != nil ? (viewModel.placeDetails?.name == "Unknown" ? placeName : viewModel.placeDetails!.name) : "Cargando...")
                            .font(.title)
                            .bold()
                        
                        // Distance
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.gray)
                            Text(distanceText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        infoBoxesView
                        
                        Divider()
                        
                        // Information Text
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text(viewModel.placeDetails?.amenity.capitalized ?? "Cargando...")
                                .font(.body)
                        }
                        
                        // Schedule Text
                        HStack(alignment: .top) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.blue)
                            Text(viewModel.placeDetails?.openingHours ?? "Cargando...")
                                .font(.body)
                        }
                    }
                    .padding()
                }
                
                bottomFavoriteButton
            }
            
            // Loading Overlay
            if viewModel.isLoading {
                ZStack {
                    Color.gray.opacity(0.4)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .red))
                        .scaleEffect(1.5)
                }
                .allowsHitTesting(false)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if viewModel.placeDetails != nil {
                    Button(action: {
                        viewModel.toggleFavorite()
                    }) {
                        Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                            .foregroundColor(viewModel.isFavorite ? .red : .gray)
                    }
                }
            }
        }
        .alert(isPresented: $bindableViewModel.showError) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "Ocurrió un error"),
                primaryButton: .default(Text("Reintentar"), action: {
                    Task {
                        // Esperar a que la alerta termine su animación de cierre
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        guard let osmId = Int(placeId) else { return }
                        await viewModel.onAppear(osmId: osmId)
                    }
                }),
                secondaryButton: .cancel(Text("Cancelar"), action: {
                    dismiss()
                })
            )
        }
        .onAppear {
            if locationManager.isAuthorized {
                locationManager.startUpdatingLocation()
            } else {
                locationManager.requestAuthorization()
            }
            Task {
                guard let osmId = Int(placeId) else { return }
                await viewModel.onAppear(osmId: osmId)
            }
        }
    }

    // MARK: - Subcomponents

    private var headerView: some View {
        Group {
            if let details = viewModel.placeDetails {
                Map(position: .constant(.region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: details.coordinate.lat, longitude: details.coordinate.lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )))) {
                    Marker(
                        details.name == "Unknown" ? placeName : details.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: details.coordinate.lat,
                            longitude: details.coordinate.lon
                        )
                    )
                }
                .disabled(true)
                .frame(height: 250)
            } else {
                ZStack {
                    Color(red: 0.85, green: 0.95, blue: 0.85)
                    Image(systemName: "map.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.2, green: 0.6, blue: 0.2))
                }
                .frame(height: 250)
            }
        }
    }

    private var infoBoxesView: some View {
        HStack(spacing: 16) {
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.orange)
                Text(viewModel.placeDetails != nil ? "4.5" : "Cargando...")
                    .font(viewModel.placeDetails != nil ? .body : .caption)
                    .bold()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 12)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(12)

            HStack {
                let status = openStatusData
                Image(systemName: "door.left.hand.open")
                    .foregroundColor(status.color)
                Text(status.text)
                    .font(viewModel.placeDetails != nil ? .subheadline : .caption)
                    .bold()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 12)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(12)
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    private var bottomFavoriteButton: some View {
        Button(action: {
            viewModel.toggleFavorite()
        }) {
            HStack {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? .red : .gray)
                Text(viewModel.isFavorite ? "Desmarcar como favorito" : "Marcar como favorito")
                    .foregroundColor(.primary)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(16)
            .padding()
        }
    }
}

#if DEBUG
private class ATP_MockFetchPlaceDetailsUC: FetchPlaceDetailsUC {
    var result: Result<AboutThePlaceEntity, Error> = .failure(NSError(domain: "", code: 0, userInfo: nil))
    func execute(_ input: Int) async -> Result<AboutThePlaceEntity, Error> {
        return result
    }
}

private class ATP_MockCheckFavoriteStatusUC: CheckFavoriteStatusUC {
    var result: Result<Bool, Error> = .success(false)
    func execute(_ input: CheckFavoriteStatusInput) async -> Result<Bool, Error> {
        return result
    }
}

private class ATP_MockToggleFavoritePlaceUC: ToggleFavoritePlaceUC {
    func execute(_ input: FavoritePlaceEntity) async -> Result<Void, Error> {
        return .success(())
    }
}

private class ATP_MockRestoreSignInUC: RestoreSignInUC {
    func execute() async -> Result<LoginEntity, Error> {
        return .success(LoginEntity(id: "1", name: "User", email: "user@example.com", profileImageURL: nil))
    }
}

private class ATP_MockSlowFetchPlaceDetailsUC: FetchPlaceDetailsUC {
    func execute(_ input: Int) async -> Result<AboutThePlaceEntity, Error> {
        try? await Task.sleep(nanoseconds: 100_000_000_000)
        return .failure(NSError(domain: "", code: 0, userInfo: nil))
    }
}

#Preview("Idle / Loading") {
    DependencyContainer.registerSingleton((any FetchPlaceDetailsUC).self, ATP_MockSlowFetchPlaceDetailsUC())
    DependencyContainer.registerSingleton((any CheckFavoriteStatusUC).self, ATP_MockCheckFavoriteStatusUC())
    DependencyContainer.registerSingleton((any ToggleFavoritePlaceUC).self, ATP_MockToggleFavoritePlaceUC())
    DependencyContainer.registerSingleton((any RestoreSignInUC).self, ATP_MockRestoreSignInUC())
    
    let view = NavigationStack {
        AboutThePlaceView(placeId: "1", placeName: "El Buen Café")
    }
    return view
}

#Preview("Loaded Map") {
    let mockFetch = ATP_MockFetchPlaceDetailsUC()
    mockFetch.result = .success(AboutThePlaceEntity(
        osmId: 1, name: "El Buen Café", coordinate: AboutThePlaceEntity.Coordinate(lat: 19.4326, lon: -99.1332), amenity: "Cafetería", openingHours: "08:00 - 20:00"
    ))
    
    let mockFav = ATP_MockCheckFavoriteStatusUC()
    mockFav.result = .success(true)
    
    DependencyContainer.registerSingleton((any FetchPlaceDetailsUC).self, mockFetch)
    DependencyContainer.registerSingleton((any CheckFavoriteStatusUC).self, mockFav)
    DependencyContainer.registerSingleton((any ToggleFavoritePlaceUC).self, ATP_MockToggleFavoritePlaceUC())
    DependencyContainer.registerSingleton((any RestoreSignInUC).self, ATP_MockRestoreSignInUC())
    
    let view = NavigationStack {
        AboutThePlaceView(placeId: "1", placeName: "El Buen Café")
    }
    return view
}

#Preview("Error State") {
    let mockFetch = ATP_MockFetchPlaceDetailsUC()
    mockFetch.result = .failure(NSError(domain: "Network", code: -1, userInfo: [NSLocalizedDescriptionKey: "Hubo un problema de conexión al servidor."]))
    
    DependencyContainer.registerSingleton((any FetchPlaceDetailsUC).self, mockFetch)
    DependencyContainer.registerSingleton((any CheckFavoriteStatusUC).self, ATP_MockCheckFavoriteStatusUC())
    DependencyContainer.registerSingleton((any ToggleFavoritePlaceUC).self, ATP_MockToggleFavoritePlaceUC())
    DependencyContainer.registerSingleton((any RestoreSignInUC).self, ATP_MockRestoreSignInUC())
    
    let view = NavigationStack {
        AboutThePlaceView(placeId: "1", placeName: "El Buen Café")
    }
    return view
}
#endif
