//
//  LocationManager.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import Foundation
import CoreLocation
import MapKit
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var speed: Double = 0.0
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.334900, longitude: -122.009020),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        
        DispatchQueue.main.async {
            withAnimation {
                self.location = latestLocation
                self.region.center = latestLocation.coordinate
                self.speed = max(latestLocation.speed, 0) * 2.23694
            }
        }
    }
    
    func recenterMapAboveOverlay() {
        let latOffset = region.span.latitudeDelta * -0.2
        let newCenter = CLLocationCoordinate2D(
            latitude: region.center.latitude + latOffset,
            longitude: region.center.longitude
        )
        self.region.center = newCenter
    }
}
