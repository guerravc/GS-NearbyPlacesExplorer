import Foundation
import CoreLocation

@MainActor
@Observable
public final class LocationManager: NSObject {
    private let clManager = CLLocationManager()
    
    public var location: CLLocation?
    public var isDenied: Bool = false
    public var isAuthorized: Bool = false
    
    public override init() {
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorization()
    }
    
    public func requestAuthorization() {
        clManager.requestWhenInUseAuthorization()
    }
    
    public func requestLocation() {
        clManager.requestLocation()
    }
    
    public func startUpdatingLocation() {
        clManager.startMonitoringSignificantLocationChanges()
    }
    
    public func stopUpdatingLocation() {
        clManager.stopMonitoringSignificantLocationChanges()
    }
    
    private func checkAuthorization() {
        switch clManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            isDenied = false
            if location == nil {
                clManager.startMonitoringSignificantLocationChanges()
            }
        case .denied, .restricted:
            isDenied = true
            isAuthorized = false
        case .notDetermined:
            isDenied = false
            isAuthorized = false
        @unknown default:
            isDenied = false
            isAuthorized = false
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.checkAuthorization()
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.location = location
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            print("LocationManager failed: \(error.localizedDescription)")
        }
    }
}
