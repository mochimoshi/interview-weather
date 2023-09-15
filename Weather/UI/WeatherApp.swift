//
//  WeatherApp.swift
//  Weather
//
//  Created by Alex Yuh-Rern Wang on 9/13/23.
//

import SwiftUI

@main
struct WeatherApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationView {
                WeatherListView()
                    .navigationTitle("Weather")
            }
        }
    }
}
