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
        if let latestLocation = locations.last {
            DispatchQueue.main.async {
                withAnimation {
                    self.region.center = latestLocation.coordinate
                    self.recenterMapAboveOverlay()
                    self.speed = max(latestLocation.speed, 0) * 2.23694 // converts to mph
                }
            }
        }
    }
    
    func recenterMapAboveOverlay() {
        // Suppose region.span.latitudeDelta is how tall your map is in degrees
        // We can shift the center up by half that to keep the dot near the vertical center
        let latOffset = region.span.latitudeDelta * -0.2
        let newCenter = CLLocationCoordinate2D(
            latitude: region.center.latitude + latOffset,
            longitude: region.center.longitude
        )
        self.region.center = newCenter
    }
    
}
