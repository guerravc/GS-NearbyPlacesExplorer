// AI-ASSISTED: generated with Antigravity IDE (gemini 3.1 pro)
import Foundation
import CoreLocation

/// Observable wrapper around `CLLocationManager` that provides the user's location
/// and authorization status to SwiftUI views.
///
/// Run exclusively on the `@MainActor` so published state changes are always
/// picked up by the SwiftUI observation system without manual dispatching.
@MainActor
@Observable
public final class LocationManager: NSObject {
    private let clManager = CLLocationManager()
    
    /// Most recently received user location. `nil` until a location fix is obtained.
    public var location: CLLocation?
    /// `true` when the user has explicitly denied or restricted location access.
    public var isDenied: Bool = false
    /// `true` when the app is authorized to receive location updates.
    public var isAuthorized: Bool = false
    
    public override init() {
        super.init()
        clManager.delegate = self
        clManager.desiredAccuracy = kCLLocationAccuracyBest
        checkAuthorization()
    }
    
    /// Presents the system location permission prompt.
    public func requestAuthorization() {
        clManager.requestWhenInUseAuthorization()
    }
    
    /// Requests a single, one-time location fix from the system.
    public func requestLocation() {
        clManager.requestLocation()
    }
    
    /// Begins monitoring significant location changes (battery-efficient).
    public func startUpdatingLocation() {
        clManager.startMonitoringSignificantLocationChanges()
    }
    
    /// Stops significant-location-change monitoring.
    public func stopUpdatingLocation() {
        clManager.stopMonitoringSignificantLocationChanges()
    }
    
    /// Evaluates the current `CLAuthorizationStatus` and updates `isAuthorized` / `isDenied`.
    /// Also starts location monitoring automatically when permission is granted.
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
