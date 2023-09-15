//
//  CLPlacemark+String.swift
//  Weather
//
//  Created by Alex Wang on 9/15/23.
//

import Foundation
import CoreLocation

extension CLPlacemark {
    var displayName: String {
        var string = ""
        if let subLocality = subLocality {
            string += "\(subLocality)"
        }
        
        if let locality = locality {
            if !string.isEmpty {
                string += ", "
            }
            string += locality
        }
        
        if let administrativeArea = administrativeArea {
            if !string.isEmpty {
                string += ", "
            }
            string += administrativeArea
        }
        
        if string.isEmpty {
            return name ?? ""
        }
        
        return string
    }
}
