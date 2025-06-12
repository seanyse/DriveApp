//
//  GyroManager.swift
//  Drive
//
//  Created by Sean Yan on 4/4/25.
//

import Foundation
import SwiftUI
import CoreMotion

class GyroManager: ObservableObject {
    private let motionManager = CMMotionManager()
    @Published var rotationRate: CMRotationRate?

    init() {
        // Check if the gyroscope is available
        if motionManager.isGyroAvailable {
            // Set the update interval to 100 Hz
            motionManager.gyroUpdateInterval = 1.0 / 100.0
            
            // Start receiving gyroscope updates
            motionManager.startGyroUpdates(to: OperationQueue.main) { [weak self] data, error in
                if let data = data {
                    // Update the published property on the main thread
                    DispatchQueue.main.async {
                        self?.rotationRate = data.rotationRate
                    }
                }
            }
        }
    }
    
    deinit {
        // Stop updates when the manager is deallocated
        motionManager.stopGyroUpdates()
    }
}
