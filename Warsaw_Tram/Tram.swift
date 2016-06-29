//
//  TramViewModel.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 26/06/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

import UIKit
import CoreLocation

class Tram {

    var number: String
    var lattitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var lowFloor: Bool
    var status: String
    
    init? (tram: [String: AnyObject]) {
        
        guard let line = tram["FirstLine"] as? String,
            let lat = tram["Lat"] as? CLLocationDegrees,
            let lon = tram["Lon"] as? CLLocationDegrees,
            let lowFloor = tram["LowFloor"] as? Bool,
            let status = tram["Status"] as? String else {
                return nil
            }
        
        self.number = line
        self.lattitude = lat
        self.longitude = lon
        self.lowFloor = lowFloor
        self.status = status
    }
}
