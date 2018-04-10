//
//  LocationApi.swift
//  BeerHere
//
//  Created by issd on 10/04/2018.
//  Copyright © 2018 issd. All rights reserved.
//

import Foundation

import CoreLocation


final class LocationApi {
    
    private static let locationManager = CLLocationManager()
    
    static func setup(_ context : CLLocationManagerDelegate) -> Bool {
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = context
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            return true;
            }
        return false;
       }
    
    static func getCurrentLocation() -> CLLocation {
        if locationManager.location != nil {
            return locationManager.location!
            } else
        {
            print("LocationData: location nil, falling back to default location")
            return CLLocation(latitude: 51.4521272, longitude: 5.4810296)
            }
        }
}
