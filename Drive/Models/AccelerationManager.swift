//
//  AccelerationManager.swift
//  Drive
//
//  Created by Sean Yan on 3/9/25.
//

import Foundation
import CoreMotion

class AccelerationManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var acc_x: Double = 0.0
    @Published var acc_y: Double = 0.0
    @Published var acc_z: Double =  0.0
    @Published var acc_mag: Double = 0.0
    @Published var acc_log: [Double: (Double, Double, Double)] = [:]

    init() {
        startUpdates()
    }
    
    func startUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer not available")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.01 // i think this is max poll
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in // deviceMotion rather than acceleration, disregards acceleration from gravity
            guard let self = self, let data = data else { return }
            DispatchQueue.main.async {
                self.acc_x = (data.userAcceleration.x)
                self.acc_y = (data.userAcceleration.y)
                self.acc_z = (data.userAcceleration.z)
 
                self.acc_mag = sqrt(self.acc_x * self.acc_x + self.acc_y * self.acc_y + self.acc_z * self.acc_z)
                self.acc_log[self.time()] = (self.acc_x, self.acc_y, self.acc_z)
                
            }
        }
    }
    func stopUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
//    func getRotationMatrix() {
//        return motionManager.attitude.rotationMatrix
//    }
    
    func time() -> Double {
        return Date().timeIntervalSince1970
    }

    
}
