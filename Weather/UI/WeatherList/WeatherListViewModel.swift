//
//  WeatherListViewModel.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/14/23.
//

import Foundation

class WeatherListViewModel {
    enum Section {
        case currentWeather
        case history
    }
    
    // TableView Data
    private(set) var sections = [Section.currentWeather, Section.history]
    
    // Weather history
    @Published private(set) var locations: [Weather25]
    
    init(locations: [Weather25] = []) {
        if !locations.isEmpty {
            self.locations = locations
        } else {
            let history = CityWeather.fetchRecent()
            let jsonDecoder = JSONDecoder()
            self.locations = history.compactMap { weather in
                guard let data = weather.weatherData else { return nil }
                return try? jsonDecoder.decode(Weather25.self, from: data)
            }
        }
    }
}
