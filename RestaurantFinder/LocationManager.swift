//
//  LocationManager.swift
//  RestaurantFinder
//
//  Created by Sahil Gangele on 8/25/16.
//  Copyright © 2016 Treehouse. All rights reserved.
//

import Foundation
import CoreLocation


extension Coordinate {
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}

final class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var onLocationFix: ((Coordinate) -> Void)?
    
    override init() {
        super.init()
        self.manager.delegate = self
        self.manager.desiredAccuracy = kCLLocationAccuracyBest
        self.manager.requestLocation()
    }
    
    func getPermission() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            
            self.manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        
        let coordinate = Coordinate(location: location)
        
        if let onLocationFix = self.onLocationFix {
            onLocationFix(coordinate)
        }
    }
}
