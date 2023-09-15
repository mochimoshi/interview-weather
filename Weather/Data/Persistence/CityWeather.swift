//
//  CityWeather.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/14/23.
//

import Foundation
import CoreData

class CityWeather: NSManagedObject {
    static let maxHistoryCount = 10
    
    @discardableResult
    class func upsert(weatherData: Weather25, context: NSManagedObjectContext = .shared) -> CityWeather? {
        guard let weatherJson = try? JSONEncoder().encode(weatherData) else {
            // Improperly formatted data.
            return nil
        }
        
        if let cityWeather = CityWeather.find(id: weatherData.id, context: context) {
            cityWeather.weatherData = weatherJson
            cityWeather.lastUpdated = Date()
            return cityWeather
        }
        
        let cityWeather = CityWeather(context: context)
        cityWeather.id = Int64(weatherData.id)
        cityWeather.displayName = weatherData.name
        cityWeather.lat = weatherData.coordinates.lat
        cityWeather.long = weatherData.coordinates.lon
        cityWeather.weatherData = weatherJson
        cityWeather.lastUpdated = Date()
        
        return cityWeather
    }
    
    class func find(id: Int, context: NSManagedObjectContext = .shared) -> CityWeather? {
        let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "id == %ld", id)
        return (try? context.fetch(request))?.first
    }
    
    class func fetchRecent(context: NSManagedObjectContext = .shared) -> [CityWeather] {
        let request: NSFetchRequest<CityWeather> = CityWeather.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [.init(key: "lastUpdated", ascending: false)]
        request.fetchLimit = maxHistoryCount
        
        return (try? context.fetch(request)) ?? []
    }
}
