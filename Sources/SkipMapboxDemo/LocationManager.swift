//
//  LocationManager.swift
//
//
//  Created by John Bent on 9/6/24.
//
#if !SKIP
import Foundation
import CoreLocation

@Observable
final class LocationManager {
    var location: CLLocation? = nil
    
    private let locationManager = CLLocationManager()
    
    func requestUserAuthorization() async throws {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() async throws {
        for try await locationUpdate in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdate.location else { return }

            self.location = location
        }
    }
}
#endif
