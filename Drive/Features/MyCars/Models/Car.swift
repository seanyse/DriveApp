//
//  Car.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import Foundation
import SwiftUI

struct Car: Identifiable, Hashable, Codable {
    var id: UUID
    var make: String
    var model: String
    var year: Int
    var horsepower: Int
    var mileage: Int
    var licensePlate: String?
    var vin: String?
    
    // Image data stored as base64 string for persistence
    var mainImageData: Data?
    
    // Additional stats
    var torque: Int?
    var engine: String?
    var transmission: String?
    var drivetrain: String?
    var color: String?
    
    // Picture gallery (stored as Data array)
    var galleryImages: [Data]
    
    // Maintenance and modification logs
    var maintenanceLogs: [MaintenanceLog]
    var modificationLogs: [ModificationLog]
    
    // Routine maintenance tracking
    var lastOilChangeMileage: Int?
    var lastOilChangeDate: Date?
    var lastTireRotationMileage: Int?
    var lastTireRotationDate: Date?
    var lastTireReplacementMileage: Int?
    var lastTireReplacementDate: Date?
    var lastBrakeInspectionMileage: Int?
    var lastBrakeInspectionDate: Date?
    
    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        year: Int,
        horsepower: Int,
        mileage: Int,
        licensePlate: String? = nil,
        vin: String? = nil,
        mainImageData: Data? = nil,
        torque: Int? = nil,
        engine: String? = nil,
        transmission: String? = nil,
        drivetrain: String? = nil,
        color: String? = nil,
        galleryImages: [Data] = [],
        maintenanceLogs: [MaintenanceLog] = [],
        modificationLogs: [ModificationLog] = []
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.horsepower = horsepower
        self.mileage = mileage
        self.licensePlate = licensePlate
        self.vin = vin
        self.mainImageData = mainImageData
        self.torque = torque
        self.engine = engine
        self.transmission = transmission
        self.drivetrain = drivetrain
        self.color = color
        self.galleryImages = galleryImages
        self.maintenanceLogs = maintenanceLogs
        self.modificationLogs = modificationLogs
    }
    
    var displayName: String {
        "\(year) \(make) \(model)"
    }
    
    // Service summary calculations
    var totalMaintenanceCost: Double {
        maintenanceLogs.reduce(0) { $0 + $1.cost }
    }
    
    var totalModificationCost: Double {
        modificationLogs.reduce(0) { $0 + $1.cost }
    }
    
    var totalServiceCost: Double {
        totalMaintenanceCost + totalModificationCost
    }
}

