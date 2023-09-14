//
//  Weather25.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/14/23.
//

import Foundation

// Model representing the response returned by v2.5 of openweathermap
struct Weather25: Codable {
    var id: Int
    var name: String
    var timezone: Int
    var coordinates: WeatherCoordinates
    var weatherCondition: [WeatherCondition]
    var currentWeather: CurrentWeather
    var visibility: Int
    var wind: Wind
    var clouds: Clouds
    var dayInformation: DayInformation
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case timezone
        case coordinates = "coord"
        case weatherCondition = "weather"
        case currentWeather = "main"
        case visibility
        case wind
        case clouds
        case dayInformation = "sys"
    }
    
    struct WeatherCoordinates: Codable {
        var lat: Double
        var lon: Double
    }

    struct WeatherCondition: Codable {
        var id: Int
        var main: String
        var description: String
    }

    struct CurrentWeather: Codable {
        // These units are in Kelvin.
        var temp: Double
        var feelsLike: Double
        var tempMin: Double
        var tempMax: Double
        
        var pressure: Int
        var humidity: Int
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
            case pressure
            case humidity
        }
    }

    struct Wind: Codable {
        var speed: Double
        var deg: Int
        var gust: Double
    }

    struct Clouds: Codable {
        var all: Int
    }
    
    struct DayInformation: Codable {
        var id: Int
        var country: String
        var sunrise: TimeInterval
        var sunset: TimeInterval
    }
}
