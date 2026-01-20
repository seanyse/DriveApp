//
//  RecordingManager.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import Foundation
import CoreLocation
import Combine

// MARK: - Drive Data Model

// MARK: - Drive Data Model

struct DriveData: Codable, Identifiable, Equatable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let distance: Double // miles
    let topSpeed: Double // mph
    let averageSpeed: Double // mph
    let greatestAcceleration: Double // mph/s
    let elevationGain: Double // feet
    let elevationLoss: Double // feet
    let minElevation: Double // feet
    let maxElevation: Double // feet
    let routeCoordinates: [CoordinatePoint]
    let speedSamples: [SpeedSample]
    let elevationSamples: [ElevationSample]
    
    struct CoordinatePoint: Codable, Equatable {
        let latitude: Double
        let longitude: Double
        let timestamp: TimeInterval
        
        var coordinate: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    struct SpeedSample: Codable, Equatable {
        let speed: Double
        let timestamp: TimeInterval
    }
    
    struct ElevationSample: Codable, Equatable {
        let elevation: Double
        let timestamp: TimeInterval
    }
}

// MARK: - Recording Manager

class RecordingManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var isRecording = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0
    @Published var currentSpeed: Double = 0
    @Published var topSpeed: Double = 0
    @Published var averageSpeed: Double = 0
    @Published var greatestAcceleration: Double = 0
    @Published var currentElevation: Double = 0
    @Published var elevationGain: Double = 0
    @Published var elevationLoss: Double = 0
    
    // Completed drive data for summary
    @Published var completedDrive: DriveData?
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    private var lastLocation: CLLocation?
    private var lastSpeed: Double = 0
    private var lastSpeedTimestamp: Date?
    private var lastElevation: Double?
    
    // Sampling control for performance
    private var locationUpdateCount = 0
    private let routeSampleInterval = 3 // Store every 3rd location for route
    private let statsSampleInterval = 5 // Sample stats every 5 updates
    
    // Raw data collection
    private var routeCoordinates: [DriveData.CoordinatePoint] = []
    private var speedSamples: [DriveData.SpeedSample] = []
    private var elevationSamples: [DriveData.ElevationSample] = []
    private var allSpeeds: [Double] = []
    
    // Elevation tracking
    private var minElevation: Double = .greatestFiniteMagnitude
    private var maxElevation: Double = -.greatestFiniteMagnitude
    
    // Start time reference
    private var startTime: Date?
    
    // MARK: - Formatted Properties
    
    var formattedTime: String {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedSpeed: String {
        String(format: "%.1f", currentSpeed)
    }
    
    var formattedDistance: String {
        String(format: "%.2f", distance)
    }
    
    var formattedTopSpeed: String {
        String(format: "%.1f", topSpeed)
    }
    
    var formattedAverageSpeed: String {
        String(format: "%.1f", averageSpeed)
    }
    
    var formattedAcceleration: String {
        String(format: "%.1f", greatestAcceleration)
    }
    
    var formattedElevation: String {
        String(format: "%.0f", currentElevation)
    }
    
    var formattedElevationGain: String {
        String(format: "%.0f", elevationGain)
    }
    
    // MARK: - Recording Control
    
    func startRecording() {
        isRecording = true
        startTime = Date()
        resetStats()
        
        // Start timer with reasonable interval
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime += 1
            self.updateAverageSpeed()
        }
    }
    
    func stopRecording() {
        isRecording = false
        timer?.invalidate()
        timer = nil
        
        // Generate completed drive data
        completedDrive = generateDriveData()
    }
    
    func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
    
    func reset() {
        stopRecording()
        resetStats()
        completedDrive = nil
    }
    
    private func resetStats() {
        elapsedTime = 0
        distance = 0
        currentSpeed = 0
        topSpeed = 0
        averageSpeed = 0
        greatestAcceleration = 0
        currentElevation = 0
        elevationGain = 0
        elevationLoss = 0
        
        lastLocation = nil
        lastSpeed = 0
        lastSpeedTimestamp = nil
        lastElevation = nil
        locationUpdateCount = 0
        
        routeCoordinates = []
        speedSamples = []
        elevationSamples = []
        allSpeeds = []
        
        minElevation = .greatestFiniteMagnitude
        maxElevation = -.greatestFiniteMagnitude
    }
    
    // MARK: - Location Updates
    
    func updateLocation(_ location: CLLocation) {
        let speedMph = max(location.speed, 0) * 2.23694
        currentSpeed = speedMph
        
        // Update elevation (convert meters to feet)
        let elevationFeet = location.altitude * 3.28084
        currentElevation = elevationFeet
        
        guard isRecording else { return }
        
        locationUpdateCount += 1
        let timestamp = elapsedTime
        
        // Update top speed
        if speedMph > topSpeed {
            topSpeed = speedMph
        }
        
        // Track speed for average calculation
        if speedMph > 0.5 { // Only count when actually moving
            allSpeeds.append(speedMph)
        }
        
        // Calculate acceleration
        updateAcceleration(currentSpeed: speedMph)
        
        // Update elevation stats
        updateElevation(elevationFeet)
        
        // Sample route coordinates (every Nth update for performance)
        if locationUpdateCount % routeSampleInterval == 0 {
            let point = DriveData.CoordinatePoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                timestamp: timestamp
            )
            routeCoordinates.append(point)
        }
        
        // Sample detailed stats less frequently
        if locationUpdateCount % statsSampleInterval == 0 {
            speedSamples.append(DriveData.SpeedSample(speed: speedMph, timestamp: timestamp))
            elevationSamples.append(DriveData.ElevationSample(elevation: elevationFeet, timestamp: timestamp))
        }
        
        // Calculate distance
        if let lastLocation = lastLocation {
            // Only add distance if accuracy is reasonable and speed indicates movement
            if location.horizontalAccuracy < 50 && speedMph > 1 {
                let deltaDistance = location.distance(from: lastLocation)
                // Sanity check: ignore jumps > 100 meters between updates
                if deltaDistance < 100 {
                    distance += deltaDistance / 1609.34
                }
            }
        }
        
        lastLocation = location
    }
    
    private func updateAcceleration(currentSpeed: Double) {
        let now = Date()
        
        if let lastTimestamp = lastSpeedTimestamp {
            let timeDelta = now.timeIntervalSince(lastTimestamp)
            
            // Only calculate if we have a reasonable time delta
            if timeDelta > 0.1 && timeDelta < 2.0 {
                let speedDelta = currentSpeed - lastSpeed
                let acceleration = speedDelta / timeDelta // mph per second
                
                // Only track positive acceleration
                if acceleration > greatestAcceleration {
                    greatestAcceleration = acceleration
                }
            }
        }
        
        lastSpeed = currentSpeed
        lastSpeedTimestamp = now
    }
    
    private func updateElevation(_ elevation: Double) {
        // Update min/max
        if elevation < minElevation {
            minElevation = elevation
        }
        if elevation > maxElevation {
            maxElevation = elevation
        }
        
        // Calculate gain/loss
        if let lastElev = lastElevation {
            let delta = elevation - lastElev
            
            // Use threshold to filter GPS noise (5 feet)
            if delta > 5 {
                elevationGain += delta
            } else if delta < -5 {
                elevationLoss += abs(delta)
            }
        }
        
        lastElevation = elevation
    }
    
    private func updateAverageSpeed() {
        guard !allSpeeds.isEmpty else {
            averageSpeed = 0
            return
        }
        averageSpeed = allSpeeds.reduce(0, +) / Double(allSpeeds.count)
    }
    
    // MARK: - Generate Drive Data
    
    private func generateDriveData() -> DriveData {
        DriveData(
            id: UUID(),
            date: startTime ?? Date(),
            duration: elapsedTime,
            distance: distance,
            topSpeed: topSpeed,
            averageSpeed: averageSpeed,
            greatestAcceleration: greatestAcceleration,
            elevationGain: elevationGain,
            elevationLoss: elevationLoss,
            minElevation: minElevation == .greatestFiniteMagnitude ? 0 : minElevation,
            maxElevation: maxElevation == -.greatestFiniteMagnitude ? 0 : maxElevation,
            routeCoordinates: routeCoordinates,
            speedSamples: speedSamples,
            elevationSamples: elevationSamples
        )
    }
}
