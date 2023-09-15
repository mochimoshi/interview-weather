//
//  CityWeather.swift
//  Weather
//
//  Created by Alex Wang on 9/14/23.
//

import Foundation
import CoreData

class CityWeather: NSManagedObject {
    static let maxHistoryCount = 10
    
    @discardableResult
    class func upsert(weatherData: Weather25,
                      // Placemark name prefers the name given by CoreLocation's Geocoder over
                      // OpenWeather's, as it tends to be more complete (e.g. Springfield, IL vs. Springfield)
                      placemarkName: String?,
                      context: NSManagedObjectContext = .shared) -> CityWeather? {
        
        func updateExistingCity(cityWeather: CityWeather, data: Data) {
            cityWeather.weatherData = data
            cityWeather.lastUpdated = Date()
            cityWeather.lastLoaded = Date()
        }
        
        guard let weatherJson = try? JSONEncoder().encode(weatherData) else {
            // Improperly formatted data.
            return nil
        }
        
        if let cityWeather = CityWeather.find(id: weatherData.id, context: context) {
            updateExistingCity(cityWeather: cityWeather, data: weatherJson)
            return cityWeather
        }
        
        // If an existing city display name also exists, we'll just update that instead as well
        if let placemarkName = placemarkName,
           let cityWeather = CityWeather.find(displayName: placemarkName) {
            updateExistingCity(cityWeather: cityWeather, data: weatherJson)
            return cityWeather
        }
        
        let cityWeather = CityWeather(context: context)
        cityWeather.id = Int64(weatherData.id)
        cityWeather.displayName = placemarkName ?? weatherData.name
        cityWeather.lat = weatherData.coordinates.lat
        cityWeather.long = weatherData.coordinates.lon
        cityWeather.weatherData = weatherJson
        cityWeather.lastUpdated = Date()
        cityWeather.lastLoaded = Date()
        
        try? context.save()
        
        // TODO: Also limit the database to a set size so it doesn't grow infinitely
        
        return cityWeather
    }
    
    class func find(id: Int, context: NSManagedObjectContext = .shared) -> CityWeather? {
        let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == %ld", id)
        return (try? context.fetch(request))?.first
    }
    
    class func find(displayName: String, context: NSManagedObjectContext = .shared) -> CityWeather? {
        let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "displayName == %@", displayName)
        return (try? context.fetch(request))?.first
    }
    
    class func fetchRecent(context: NSManagedObjectContext = .shared) -> [CityWeather] {
        let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [.init(key: "lastLoaded", ascending: false)]
        request.fetchLimit = maxHistoryCount
        
        return (try? context.fetch(request)) ?? []
    }
    
    func updateLoadedTime(context: NSManagedObjectContext = .shared) {
        lastLoaded = Date()
        
        try? context.save()
    }
}
