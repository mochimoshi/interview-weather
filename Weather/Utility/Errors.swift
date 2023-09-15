//
//  Errors.swift
//  Weather
//
//  Created by Alex Wang on 9/15/23.
//

import Foundation

enum WeatherServiceError: Error, LocalizedError {
    case noWeatherInformationReturned
    
    // These should be localized strings. For now, we'll go with regular strings.
    var errorDescription: String? {
        switch self {
        case .noWeatherInformationReturned:
            return "No weather information found for coordinates"
        }
    }
}

enum LocationManagerError: Error, LocalizedError {
    case noCoordinatesAvailableForAddress
    case noLocationPermissions
    case noLocationFoundForUser
    case unexpectedError
    
    // These should be localized strings. For now, we'll go with regular strings.
    var errorDescription: String? {
        switch self {
        case .noCoordinatesAvailableForAddress:
            return "No coordinates found for address"
        case .noLocationPermissions:
            return "Location access denied. Please grant location access in Settings."
        case .noLocationFoundForUser:
            return "No location can be found for user. Try again later."
        case .unexpectedError:
            return "Unexpected error while getting user location."
        }
    }
}

enum APIClientError: Error, LocalizedError {
    case invalidRequest
    
    // These should be localized strings. For now, we'll go with regular strings.
    var errorDescription: String? {
        switch self {
        case .invalidRequest:
            return "Invalid request from server"
        }
    }
}
