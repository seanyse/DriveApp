//
//  SensorFusion.swift
//  Drive
//
//  Created by Sean Yan on 4/4/25.
//

import Foundation
import Foundation
import CoreMotion
import Combine

class SensorFusion: ObservableObject {
    
    
    private let aManager = AccelerationManager()
    private let gManager = GyroManager()
    private let lManager = LocationManager()
    
    private let motionManager = CMMotionManager()
    private var lastUpdateTime: TimeInterval?
    
    // Integrated forward velocity in m/s
    @Published var velocity: Double = 0.0
    // 0-60 run elapsed time in seconds
    @Published var elapsedTime: TimeInterval = 0.0

    // Forward target: 60 mph -> 26.82 m/s
    private let targetVelocity = 26.82

    // A simple filter to reduce noise in the measured forward acceleration.
    private let filterConstant = 0.1
    private var filteredForwardAcc: Double = 0.0

    init() {
        if motionManager.isDeviceMotionAvailable {
            // Use a high update frequency if needed; adjust as required.
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] dm, error in
                guard let self = self, let dm = dm else { return }
                self.processDeviceMotion(dm)
            }
        }
    }
    
    private func processDeviceMotion(_ dm: CMDeviceMotion) {
        // Get the acceleration without gravity. This data is already gravity-corrected.
        let userAcc = dm.userAcceleration
        
        // The device’s attitude (coming from sensor fusion using the gyroscope and accelerometer)
        // provides the rotation matrix. In this example we assume that the car’s forward direction is
        // aligned with the device’s x-axis in its fixed (world) coordinate system after transformation.
        let rm = dm.attitude.rotationMatrix
        
        // Transform the raw acceleration vector from device coordinates to the fixed vehicle-aligned frame.
        // The forward acceleration component is calculated by projecting onto what we define as the forward axis.
        let forwardAcc = rm.m11 * userAcc.x + rm.m12 * userAcc.y + rm.m13 * userAcc.z
        
        // Low-pass filter to reduce sensor noise (simple exponential smoothing)
        filteredForwardAcc = filterConstant * forwardAcc + (1 - filterConstant) * filteredForwardAcc
        
        let currentTime = dm.timestamp
        if lastUpdateTime == nil {
            // Initialize timing when the measurements start (e.g., when at rest)
            lastUpdateTime = currentTime
            velocity = 0.0
            elapsedTime = 0.0
            return
        }
        
        // Calculate the elapsed time since the last update.
        let deltaTime = currentTime - lastUpdateTime!
        lastUpdateTime = currentTime
        
        // Integrate the forward acceleration to update velocity.
        velocity += filteredForwardAcc * deltaTime
        elapsedTime += deltaTime
        
        // Check if the target velocity (60 mph) is reached.
        if velocity >= targetVelocity {
            print("0-60 time: \(elapsedTime) seconds")
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
//    deinit {
//        motionManager.stopDeviceMotionUpdates()
//    }
//    
//    }
//    
//    @Published var speed: Double = 0
//    
//    init() {
//        setup()
//    }
//    
//    private func setup() {
//        
//    }
    
}
