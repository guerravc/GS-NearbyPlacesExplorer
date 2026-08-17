import SwiftUI
import CoreLocation

public struct PlaceListCell: View {
    public let model: NearbyPlacesEntity
    public let currentLocation: CLLocation?
    
    public init(model: NearbyPlacesEntity, currentLocation: CLLocation? = nil) {
        self.model = model
        self.currentLocation = currentLocation
    }
    
    private var distanceText: String {
        guard let currentLocation = currentLocation else { return "" }
        let placeLocation = CLLocation(latitude: model.coordinate.latitude, longitude: model.coordinate.longitude)
        let distance = currentLocation.distance(from: placeLocation)
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .naturalScale
        formatter.numberFormatter.maximumFractionDigits = 1
        
        let measurement = Measurement(value: distance, unit: UnitLength.meters)
        return formatter.string(from: measurement)
    }
    
    private var scheduleText: String {
        switch model.openingState {
        case .open: return "Abierto"
        case .closed: return "Cerrado"
        case .notAvailable: return "Horario no disponible"
        }
    }
    
    private var scheduleColor: Color {
        switch model.openingState {
        case .open: return .green
        case .closed: return .red
        case .notAvailable: return .secondary
        }
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: POICategoryMapper.map(category: model.category))
                .foregroundColor(.red)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.15))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(model.name)
                    .font(.headline)
                    .bold()
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    if !distanceText.isEmpty {
                        Text(distanceText)
                        Text("•")
                    }
                    Text(scheduleText)
                        .foregroundColor(scheduleColor)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

#Preview("PlaceListCell - No Location") {
    let place = NearbyPlacesEntity(id: "1", name: "El Buen Café", coordinate: (19.43, -99.13), category: "cafe", address: "Calle 1")
    PlaceListCell(model: place, currentLocation: nil)
        .padding()
}

#Preview("PlaceListCell - With Location") {
    let place = NearbyPlacesEntity(id: "1", name: "El Buen Café", coordinate: (19.43, -99.13), category: "cafe", address: "Calle 1")
    PlaceListCell(model: place, currentLocation: CLLocation(latitude: 19.435, longitude: -99.135))
        .padding()
}
