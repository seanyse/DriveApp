//
//  MaintenanceLog.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import Foundation
import SwiftUI

struct MaintenanceLog: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var service: String
    var mileage: Int
    var cost: Double
    var description: String?
    var receiptImageData: Data? // Receipt image stored as Data
    
    init(
        id: UUID = UUID(),
        date: Date,
        service: String,
        mileage: Int,
        cost: Double,
        description: String? = nil,
        receiptImageData: Data? = nil
    ) {
        self.id = id
        self.date = date
        self.service = service
        self.mileage = mileage
        self.cost = cost
        self.description = description
        self.receiptImageData = receiptImageData
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// Routine maintenance types
enum RoutineMaintenanceType: String, CaseIterable, Codable {
    case oilChange = "Oil Change"
    case tireRotation = "Tire Rotation"
    case tireReplacement = "Tire Replacement"
    case brakeInspection = "Brake Inspection"
    case brakeService = "Brake Service"
    case airFilter = "Air Filter"
    case coolantFlush = "Coolant Flush"
    case transmissionService = "Transmission Service"
    
    var recommendedIntervalMiles: Int {
        switch self {
        case .oilChange: return 5000
        case .tireRotation: return 7000
        case .tireReplacement: return 50000
        case .brakeInspection: return 10000
        case .brakeService: return 30000
        case .airFilter: return 15000
        case .coolantFlush: return 30000
        case .transmissionService: return 60000
        }
    }
    
    var recommendedIntervalMonths: Int {
        switch self {
        case .oilChange: return 6
        case .tireRotation: return 6
        case .tireReplacement: return 60
        case .brakeInspection: return 12
        case .brakeService: return 24
        case .airFilter: return 12
        case .coolantFlush: return 24
        case .transmissionService: return 60
        }
    }
}

struct MaintenanceReminder: Identifiable {
    let id: UUID
    let type: RoutineMaintenanceType
    let isDue: Bool
    let isOverdue: Bool
    let daysUntilDue: Int?
    let milesUntilDue: Int?
    let lastServiceDate: Date?
    let lastServiceMileage: Int?
    
    var urgencyColor: Color {
        if isOverdue {
            return .red
        } else if isDue {
            return .orange
        } else {
            return .green
        }
    }
}

// Common maintenance service types for dropdown
enum MaintenanceServiceType: String, CaseIterable {
    case oilChange = "Oil Change"
    case tireRotation = "Tire Rotation"
    case tireReplacement = "Tire Replacement"
    case brakeInspection = "Brake Inspection"
    case brakeService = "Brake Service"
    case brakePadReplacement = "Brake Pad Replacement"
    case airFilter = "Air Filter"
    case cabinAirFilter = "Cabin Air Filter"
    case coolantFlush = "Coolant Flush"
    case transmissionService = "Transmission Service"
    case transmissionFluidChange = "Transmission Fluid Change"
    case sparkPlugReplacement = "Spark Plug Replacement"
    case batteryReplacement = "Battery Replacement"
    case alignment = "Wheel Alignment"
    case suspensionInspection = "Suspension Inspection"
    case exhaustService = "Exhaust Service"
    case engineDiagnostic = "Engine Diagnostic"
    case other = "Other"
    
    var isOther: Bool {
        self == .other
    }
}

