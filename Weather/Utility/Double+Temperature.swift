//
//  Double+Temperature.swift
//  Weather
//
//  Created by Alex Wang on 9/15/23.
//

import Foundation

extension Double {
    func temperatureDisplay(isMetric: Bool) -> String {
        if isMetric {
            let value = (self - 273.15)
            return String(format: "%.1f°C", value)
        }
        
        let value = ((self - 273.15) * (9/5) + 32.0).rounded(.awayFromZero)
        return String(format: "%.0f°F", value)
    }
}
