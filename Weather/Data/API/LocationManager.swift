//
//  LocationManager.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/14/23.
//

import Foundation
import MapKit
import CoreLocation

enum LocationManagerError: Error, LocalizedError {
    case noCoordinatesAvailableForAddress
    
    // These should be localized strings. For now, we'll go with regular strings.
    var errorDescription: String? {
        switch self {
        case .noCoordinatesAvailableForAddress:
            return "No coordinates found for address"
        }
    }
}

class LocationManager {
    
    static let shared = LocationManager()
    
    let geocoder = CLGeocoder()
    
    private init() {
        
    }
    
    // Instead of hitting a paid API, we can geocode with Apple's APIs instead.
    func geocode(address: String) async throws -> (Double, Double) {
        guard let result = try await geocoder.geocodeAddressString(address).first,
              let coordinates = result.location?.coordinate else {
            print("No results retrieved while getting coordinates for address \(address).")
            throw LocationManagerError.noCoordinatesAvailableForAddress
        }
        
        return (coordinates.latitude, coordinates.longitude)
    }
}
