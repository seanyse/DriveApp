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
    // ui variables
    @Published var log: String = ""
//    user start recording
    @Published var userStart = false
    @Published var speed: Double = 0.0
    

//    accleration xyz
    var ax = 0.0
    var ay = 0.0
    var az = 0.0
    @Published var a_mag = 0.0
//    attitude
    
    var a_stamp: [a_stamp_struct] = []
    var q_stamp: [q_stamp_struct] = []
    var s_stamp: [s_stamp_struct] = []
    
//    initiate managers (accleration, gyro, and gps)
    private let motionManager = CMMotionManager()
    private let locationManager = LocationManager()
    private var cancellables = Set<AnyCancellable>()

    struct a_stamp_struct {
        let timestamp: TimeInterval
        let x: Double
        let y: Double
        let z: Double
    }
    struct q_stamp_struct {
        let timestamp: TimeInterval
        let x: Double
        let y: Double
        let z: Double
        let w: Double
    }
    struct s_stamp_struct {
        let timestamp: TimeInterval
        let x: Double
    }
    struct world_accel_struct {
        let timestamp: TimeInterval
        let x: Double
        let y: Double
        let z: Double
        let accel_mag: Double
    }
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
        if self.speed != 0 {
            log += "Speed is not zero, quitting \n"
            return
        }
        // reset all variables
        log += "Recording data...\n"
        ax = 0.0; ay = 0.0; az = 0.0;
        a_stamp = []
        q_stamp = []
        s_stamp = []
                
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let motion = data else { return }
            // User acceleration
            let userAccel = motion.userAcceleration
            // Attitude for orientation
//            let attitude = motion.attitude
//            quaternization
            let quat = motion.attitude.quaternion
            // log timestamped raw data
            let time = motion.timestamp
            let accel = a_stamp_struct(timestamp: time, x: userAccel.x, y: userAccel.y, z: userAccel.z)
            let quant = q_stamp_struct(timestamp: time, x: quat.x, y: quat.y, z: quat.z, w: quat.w)
            let speed = s_stamp_struct(timestamp: time, x: self.speed)
            
            self.a_stamp.append(accel)
            self.q_stamp.append(quant)
            self.s_stamp.append(speed)
            
            // ui stuff
            self.a_mag = sqrt(userAccel.x * userAccel.x +
                              userAccel.y * userAccel.y +
                              userAccel.z * userAccel.z)
            
            // testing
            if self.a_mag > 2 {
                print("a")
                print(a_stamp)
                print("q")
                print(q_stamp)
                print("s")
                print(s_stamp)
            }
            
            if self.speed >= 60 {
                log += "Run Complete \n"
                processData()
            }
        }
        
    }

//    wait for user start
    func processData() {
        self.stopRecording()
        
        log += "Processing Data ... \n"
        // tuning variables
        let launch_treshhold: Double = 0.5
        let target_speed: Double = 60.0
        
        var forward_vector = false
        var unit_forward: Double? = nil
        
        // launch timing variables set -1 for not found
        var initial_time: TimeInterval = -1.0
        var initial_time_index: Int = -1

        // list for rotated acceleration vectors
        var world_accel: [world_accel_struct] = []
        var accel_mag: Double = 0.0
                
        for i in 0..<self.a_stamp.count {
            
            let a = self.a_stamp[i]
            let q = self.q_stamp[i]
            // transform to world view, now we have world acceeleration
            var rotated_accel = rotateVectorByQuaternion(vx: a.x, vy: a.y, vz: a.z, qx: q.x, qy: q.y, qz: q.z, qw: q.w)
            // calculate accel_mag with respect to world view, using x and y values of rotated_accel
            accel_mag = (sqrt(pow(rotated_accel.0, 2) + pow(rotated_accel.1, 2)))
            // add to struct, then append to a list
            var world_accel_append = world_accel_struct(timestamp:a.timestamp, x:rotated_accel.0, y:rotated_accel.1, z:rotated_accel.2, accel_mag: accel_mag)
            world_accel.append(world_accel_append)
        }
        
        
        // get a better launch detection, first smooth the data using moving average,
        
        // compute gradient (difference)
        
        // threshold gradient
        // detect launch time
        for i in 0..<world_accel.count {
            // first timestamp, check if average greater than threshold
            if world_accel[i].accel_mag > launch_treshhold {
                var sum:Double = 0.0
                // gets average of next 30 magnitudes, if the average is greater than threshold, found initial_time
                for j in 0..<30 {
                    sum += world_accel[j+i].accel_mag
                }
                if sum/30.0 > launch_treshhold {
                    // found launch time
                    initial_time = world_accel[i].timestamp
                    initial_time_index = i
                    break
                }
            }
        }
        if initial_time == -1.0 || initial_time_index == -1 {
            log += "Start sequence not detected, quitting \n"
            userStart = false
            return
        }
        log += "Initial time detected at index \(initial_time_index) \n"
        
        // find forward direction, assuming foward direction is average of accel in the first .5 seconds
        let direction_window = initial_time_index + 50 // first 50 samples
        // sum x and y components
        var sum_x: Double = 0.0
        var sum_y: Double = 0.0
        
        for i in initial_time_index..<direction_window {
            sum_x += world_accel[i].x
            sum_y += world_accel[i].y
        }
        // get magnitude
        let vector_magnitude = sqrt(sum_x * sum_x + sum_y * sum_y)
        // get forward vector
        let forwardVector = (x: sum_x / vector_magnitude, y: sum_y / vector_magnitude)
        
        // start integrating from start time
    
        // experimental: what if we just calculate the last GPS timestamp before 60 mph, then just calculate velocity leading up to that point?
        // decrement from back of the s_stamp list down, to get the index before 60
        var least_timestamp = TimeInterval(0)
        var least_velocity = -1.0
        for i in stride(from:s_stamp.count - 1, through: 0, by: -1) {
            let s = self.s_stamp[i]
            // find first occurence of gps tracked speed < 60
            if (s.x < target_speed) {
                least_timestamp = s.timestamp
                least_velocity = s.x
                break
            }
        }
        // now we have the time before reaching 60, start the mappped timestamp from that point
        // get index
        var world_accel_index = -1
        for i in stride(from: world_accel.count - 1, through: 0, by: -1) {
            let w = world_accel[i]
            if (w.timestamp == least_timestamp) {
                world_accel_index = i
                break
            }
        }
        // empty final velocity list
        var calculated_velocity: [(timestamp: TimeInterval, speed: Double)] = []
        var velocity: Double = 0.0
        let inital_time = world_accel[world_accel_index].timestamp
        var final_time = world_accel[world_accel_index].timestamp
        // main integration loop
        for i in world_accel_index..<world_accel.count {
            let prev = world_accel[i-1]
            let curr = world_accel[i]
            
            
            // convert to m/s
            let accel_x_m = curr.x * 9.81
            let accel_y_m = curr.y * 9.81
            // dot world accel onto forward
            let forward_acceleration = accel_x_m * forwardVector.x + accel_y_m * forwardVector.y
            
            // time difference
            let dt = curr.timestamp - prev.timestamp
            
            // velocity
            velocity += forward_acceleration * dt
            
            calculated_velocity.append((curr.timestamp, speed: velocity))
            
            if velocity >= target_speed {
                final_time = curr.timestamp
                break
            }
        }
        
        let calculated_time = final_time - inital_time
        log += "Calculated time: \(calculated_time)\n"
  
    }
    

    func rotateVectorByQuaternion(vx: Double, vy: Double, vz: Double, qx: Double, qy: Double, qz: Double, qw: Double) -> (x: Double, y: Double, z: Double) {
        // transform from device to world frame using this formula
        // v' = q * v * q^-1
        // Quaternion conjugate (assumes unit quaternion)
        let iqx = -qx
        let iqy = -qy
        let iqz = -qz
        let iqw = qw

        // v as quaternion
        let vxq = vx
        let vyq = vy
        let vzq = vz
        let vwq = 0.0

        // temp = q * v
        let tx =  qw * vxq + qy * vzq - qz * vyq
        let ty =  qw * vyq + qz * vxq - qx * vzq
        let tz =  qw * vzq + qx * vyq - qy * vxq
        let tw = -qx * vxq - qy * vyq - qz * vzq

        // result = temp * q_conjugate
        let rx = tx * iqw + tw * iqx + ty * iqz - tz * iqy
        let ry = ty * iqw + tw * iqy + tz * iqx - tx * iqz
        let rz = tz * iqw + tw * iqz + tx * iqy - ty * iqx

        return (rx, ry, rz)
    }
    
//    stop all updates
    func stopRecording() {
        motionManager.stopDeviceMotionUpdates()
    }
    
    
}

