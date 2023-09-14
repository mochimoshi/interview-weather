//
//  WeatherApp.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/13/23.
//

import SwiftUI

@main
struct WeatherApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
