//
//  ZeroSixtyManager.swift
//  Drive
//
//  Created by Sean Yan on 4/29/25.
//

import Foundation
import CoreMotion
import CoreLocation
import Combine

class ZeroSixtyManager: ObservableObject {
//    user start recording
    @Published var userStart = false
    @Published var speed: Double = 0.0

//    accleration xyz
    var ax = 0.0
    var ay = 0.0
    var az = 0.0
    @Published var a_mag = 0.0
//    attitude
    
    var a_stamp: [TimeInterval: (Double, Double, Double)] = [:]
    var q_stamp: [TimeInterval: (Double, Double, Double, Double)] = [:]
    var s_stamp: [TimeInterval: (Double)] = [:]
    
//    initiate managers (accleration, gyro, and gps)
    private let motionManager = CMMotionManager()
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

//    initiate location
    init() {

        motionManager.accelerometerUpdateInterval = 0.01 // 100 Hz
        motionManager.gyroUpdateInterval = 0.01      // 100 Hz
        
        locationManager.$speed
               .assign(to: \.speed, on: self)
               .store(in: &cancellables)
    }

    func startRecording() {
        
        if userStart == false {
            return
        }
        print("Starting 0-60 recording...")
        ax = 0.0; ay = 0.0; az = 0.0;
        a_stamp = [:]
        q_stamp = [:]
        s_stamp = [:]
                
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let motion = data else { return }
            // User acceleration
            let userAccel = motion.userAcceleration
            // Attitude for orientation
            let attitude = motion.attitude
//            quaternization
            let quat = motion.attitude.quaternion

            // log timestamped raw data
            self.a_stamp[motion.timestamp] = (userAccel.x, userAccel.y, userAccel.z)
            self.q_stamp[motion.timestamp] = (quat.x, quat.y, quat.z, quat.w)
            self.s_stamp[motion.timestamp] = self.speed
            
            // ui stuff
            self.a_mag = sqrt(userAccel.x * userAccel.x +
                              userAccel.y * userAccel.y +
                              userAccel.z * userAccel.z)
            
            // testing
            if self.a_mag > 3 {
                print("a")
                print(a_stamp)
                print("q")
                print(q_stamp)
                print("s")
                print(s_stamp)
            }
            
            if speed >= 60 {
                processData()
            }
        }
        
    }

//    wait for user start
    func processData() {
        self.stopRecording()
        
//        find the time stamp off the launch
        
        // need to normalize acceleration data due to rumbles, vibrations etc
        // using a band-pass filter
        // check first 2 seconds of launch
        
    }
//    check speed < 0
//    grab rotation matrix
//    determine car forward direction in world frame
    
    
    
//    stop all updates
    func stopRecording() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    
}

