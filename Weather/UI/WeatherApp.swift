//
//  WeatherApp.swift
//  Weather
//
//  Created by Alex Wang on 9/13/23.
//

import SwiftUI

@main
struct WeatherApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WeatherListView()
                    .navigationTitle("Weather")
            }
        }
    }
}
