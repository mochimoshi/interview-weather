//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Alex Wang on 9/14/23.
//

import Foundation

class WeatherListViewModel {
    enum Section {
        case currentWeather
        case history
    }
    
    struct LocationWeather {
        let displayName: String
        let weather: Weather25
    }
    
    struct FormattedWeather {
        struct Temperatures {
            let current: String
            let high: String
            let low: String
            let feelsLike: String
        }
        
        let displayName: String
        let temperatures: Temperatures
        let condition: String
        let icon: URL
    }
    
    let apiClient: APIClient
    let decoder = JSONDecoder()
    
    // TableView Data
    private(set) var sections = [Section.currentWeather, Section.history]
    
    // Weather history
    @Published private(set) var locations: [LocationWeather] = []
    @Published private(set) var isLoading: Bool = false
    
    init(
        locations: [LocationWeather] = [],
        apiClient: APIClient = .shared
    ) {
        self.apiClient = apiClient
        if !locations.isEmpty {
            self.locations = locations
        } else {
            self.locations = getWeatherHistory()
        }
    }
    
    func getWeatherHistory() -> [LocationWeather] {
        let history = CityWeather.fetchRecent()
        let jsonDecoder = JSONDecoder()
        return history.compactMap { weather in
            guard let data = weather.weatherData,
                  let decodedWeather = try? jsonDecoder.decode(Weather25.self, from: data) else {
                return nil
            }
            
            return LocationWeather(
                displayName: weather.displayName ?? decodedWeather.name,
                weather: decodedWeather
            )
        }
    }
    
    func getWeather(name: String) async throws {
        defer {
            isLoading = false
        }
        
        isLoading = true
        try await apiClient.fetchWeather(location: name)
        
        locations = getWeatherHistory()
    }
    
    func getUserLocationWeather() async throws {
        defer {
            isLoading = false
        }
        
        isLoading = true
        
        try await apiClient.fetchWeatherForUserLocation()
        
        locations = getWeatherHistory()
    }
    
    func loadPreviousLocation(weather: LocationWeather) async throws {
        guard let cityWeather = CityWeather.find(displayName: weather.displayName),
              let lastUpdated = cityWeather.lastUpdated else {
            return
        }
        
        if Date().timeIntervalSinceReferenceDate - lastUpdated.timeIntervalSinceReferenceDate > 60 * 15 {
            try await getWeather(name: weather.displayName)
        } else {
            cityWeather.updateLoadedTime()
        }
        
        locations = getWeatherHistory()
    }
    
    func formatWeather(weather: LocationWeather) -> FormattedWeather {
        let isMetric = Locale.current.measurementSystem == .metric
        let temps = weather.weather.currentWeather
        let condition = weather.weather.weatherCondition.first
        
        return FormattedWeather(
            displayName: weather.displayName,
            temperatures: FormattedWeather.Temperatures(
                current: temps.temp.temperatureDisplay(isMetric: isMetric),
                high: temps.tempMax.temperatureDisplay(isMetric: isMetric),
                low: temps.tempMin.temperatureDisplay(isMetric: isMetric),
                feelsLike: temps.feelsLike.temperatureDisplay(isMetric: isMetric)
            ),
            condition: "\(condition?.main ?? "Unknown") (\(condition?.description ?? "Unknown"))",
            // If, for whatever reason, we don't have an icon, let's first use the "mist" icon as a fallback.
            // This should be handled more gracefully given more time (e.g. with a ? mark)
            icon: URL(string: "https://openweathermap.org/img/wn/\(condition?.icon ?? "50d")@2x.png")!
        )
    }
}
