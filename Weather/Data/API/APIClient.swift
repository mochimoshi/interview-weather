//
//  APIClient.swift
//  Weather
//
//  Created by Alex Wang on 9/15/23.
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    private let networkClient: NetworkClient
    private let locationManager: LocationManager
    
    init(networkClient: NetworkClient = .shared,
         locationManager: LocationManager = .shared) {
        self.networkClient = networkClient
        self.locationManager = locationManager
    }
    
    @discardableResult
    func fetchWeather(location: String, usingCache: Bool = true) async throws -> CityWeather? {
        let placemark = try await locationManager.geocode(address: location)
        
        return try await getWeather(placemark: placemark, usingCache: usingCache)
    }
    
    @discardableResult
    func fetchWeatherForUserLocation() async throws -> CityWeather? {
        let placemark = try await locationManager.coordinatesForUserLocation()
        
        return try await getWeather(placemark: placemark)
    }
    
    private func getWeather(placemark: LocationManager.Placemark,
                            usingCache: Bool = true) async throws -> CityWeather? {
        // If we already have fetched something before within the last fifteen minutes with the same display name
        // We should use that data
        if usingCache,
           let cachedCityWeather = CityWeather.find(displayName: placemark.name),
           let lastUpdate = cachedCityWeather.lastUpdated,
           Date().timeIntervalSinceReferenceDate - lastUpdate.timeIntervalSinceReferenceDate < 60 * 15 {
            cachedCityWeather.lastLoaded = Date()
            return cachedCityWeather
        }
        
        guard let weather = try await networkClient.fetchWeather(
            lat: placemark.coordinates.latitude,
            lon: placemark.coordinates.longitude
        ) else {
            throw WeatherServiceError.noWeatherInformationReturned
        }
        
        return CityWeather.upsert(weatherData: weather, placemarkName: placemark.name)
    }
}
