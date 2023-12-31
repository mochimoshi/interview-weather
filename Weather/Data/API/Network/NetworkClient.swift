//
//  NetworkClient.swift
//  Weather
//
//  Created by Alex Wang on 9/14/23.
//

import Foundation

class NetworkClient {
    private enum OpenWeatherService {
        static let baseUrl = URL(string: "https://api.openweathermap.org/data/")!
        
        // If this were a production project, I would have the API key be encrypted and in a file that is gitignore'd.
        // For the purposes of this exercise, it'll just be here in plain text so it can compile.
        static let apiKey = "b033d4e01e401c05035e9188dff3b0bc"
        
        // Flexibility given if, for example, we want to use information from the 3.0 API, or other endpoints.
        // For the purposes of this exercise, we're only using the basic free tier with API v2.5
        case weather25
        
        func endpoint() -> URL {
            switch self {
            case .weather25:
                return OpenWeatherService.baseUrl.appending(path: "2.5/weather")
            }
        }
    }
    
    static let shared = NetworkClient()
    
    private init() {
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> Weather25? {
        var endpointUrl = OpenWeatherService.weather25.endpoint()
        endpointUrl.append(
            queryItems: [URLQueryItem(name: "lat", value: String(lat)),
                         URLQueryItem(name: "lon", value: String(lon)),
                         URLQueryItem(name: "appid", value: OpenWeatherService.apiKey)]
        )
        
        return try await URLSession.shared.fetch(url: endpointUrl)
    }
}
