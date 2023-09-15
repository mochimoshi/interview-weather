//
//  LocationManager.swift
//  Weather
//
//  Created by Alex Wang on 9/14/23.
//

import Foundation
import MapKit
import CoreLocation

import AsyncLocationKit

class LocationManager {
    struct Placemark {
        let name: String
        let coordinates: CLLocationCoordinate2D
    }
    
    static let shared = LocationManager()
    
    let geocoder = CLGeocoder()
    let asyncLocationManager = AsyncLocationManager(desiredAccuracy: .kilometerAccuracy)
        
    private init() {
        
    }
    
    // Instead of hitting a paid API, we can geocode with Apple's APIs instead.
    func geocode(address: String) async throws -> Placemark {
        guard let result = try await geocoder.geocodeAddressString(address).first,
              let coordinates = result.location?.coordinate else {
            print("No results retrieved while getting coordinates for address \(address).")
            throw LocationManagerError.noCoordinatesAvailableForAddress
        }
        
        return Placemark(name: result.displayName, coordinates: coordinates)
    }
    
    func coordinatesForUserLocation() async throws -> Placemark {
        let permission = await self.asyncLocationManager.requestPermission(with: .whenInUsage)
        
        switch permission {
        case .authorizedAlways, .authorizedWhenInUse:
            let event = try await asyncLocationManager.requestLocation()
            switch event {
            case .didUpdateLocations(let locations):
                guard let location = locations.first else {
                    throw LocationManagerError.noLocationFoundForUser
                }
                
                let placemark = try await geocoder.reverseGeocodeLocation(location).first
                
                return Placemark(
                    name: placemark?.displayName ?? "Current Location",
                    coordinates: location.coordinate
                )
            case .didFailWith(let error):
                throw error
            case .didPaused, .didResume, .none:
                // These cases shouldn't happen
                throw LocationManagerError.unexpectedError
            }
        case .notDetermined:
            throw LocationManagerError.noLocationPermissions
        case .denied, .restricted:
            throw LocationManagerError.noLocationPermissions
        @unknown default:
            fatalError("New case for location permissions that is not yet implemented")
        }
    }
}
