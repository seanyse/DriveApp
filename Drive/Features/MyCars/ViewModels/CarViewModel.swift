//
//  CarViewModel.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import Foundation
import SwiftUI

class CarViewModel: ObservableObject {
    @Published var cars: [Car] = [] {
        didSet {
            saveCars()
        }
    }
    
    private let carsKey = "saved_cars"
    
    init() {
        loadCars()
    }
    
    // MARK: - Persistence
    
    private func saveCars() {
        if let encoded = try? JSONEncoder().encode(cars) {
            UserDefaults.standard.set(encoded, forKey: carsKey)
        }
    }
    
    private func loadCars() {
        if let data = UserDefaults.standard.data(forKey: carsKey),
           let decoded = try? JSONDecoder().decode([Car].self, from: data) {
            cars = decoded
        } else {
            // Load sample data if no saved data exists
            cars = [
                Car(make: "Honda", model: "Pilot", year: 2020, horsepower: 280, mileage: 56000),
                Car(make: "Audi", model: "S4", year: 2022, horsepower: 349, mileage: 56000),
                Car(make: "Ford", model: "Mustang", year: 2018, horsepower: 460, mileage: 56000)
            ]
        }
    }
    
    // MARK: - Car CRUD Operations
    
    func addCar(_ car: Car) {
        cars.append(car)
    }
    
    func updateCar(_ car: Car) {
        if let index = cars.firstIndex(where: { $0.id == car.id }) {
            cars[index] = car
        }
    }
    
    func deleteCar(_ car: Car) {
        cars.removeAll { $0.id == car.id }
    }
    
    func getCar(by id: UUID) -> Car? {
        cars.first { $0.id == id }
    }
    
    // MARK: - Maintenance Log Operations
    
    func addMaintenanceLog(to carId: UUID, log: MaintenanceLog) {
        if let index = cars.firstIndex(where: { $0.id == carId }) {
            cars[index].maintenanceLogs.append(log)
            
            // Update routine maintenance tracking
            updateRoutineMaintenance(for: &cars[index], with: log)
        }
    }
    
    func updateMaintenanceLog(carId: UUID, logId: UUID, updatedLog: MaintenanceLog) {
        if let carIndex = cars.firstIndex(where: { $0.id == carId }),
           let logIndex = cars[carIndex].maintenanceLogs.firstIndex(where: { $0.id == logId }) {
            cars[carIndex].maintenanceLogs[logIndex] = updatedLog
            
            // Recalculate routine maintenance tracking
            updateRoutineMaintenance(for: &cars[carIndex], with: updatedLog)
        }
    }
    
    func deleteMaintenanceLog(carId: UUID, logId: UUID) {
        if let index = cars.firstIndex(where: { $0.id == carId }) {
            cars[index].maintenanceLogs.removeAll { $0.id == logId }
        }
    }
    
    // MARK: - Modification Log Operations
    
    func addModificationLog(to carId: UUID, log: ModificationLog) {
        if let index = cars.firstIndex(where: { $0.id == carId }) {
            cars[index].modificationLogs.append(log)
        }
    }
    
    func updateModificationLog(carId: UUID, logId: UUID, updatedLog: ModificationLog) {
        if let carIndex = cars.firstIndex(where: { $0.id == carId }),
           let logIndex = cars[carIndex].modificationLogs.firstIndex(where: { $0.id == logId }) {
            cars[carIndex].modificationLogs[logIndex] = updatedLog
        }
    }
    
    func deleteModificationLog(carId: UUID, logId: UUID) {
        if let index = cars.firstIndex(where: { $0.id == carId }) {
            cars[index].modificationLogs.removeAll { $0.id == logId }
        }
    }
    
    // MARK: - Gallery Operations
    
    func addGalleryImage(to carId: UUID, imageData: Data) {
        if let index = cars.firstIndex(where: { $0.id == carId }) {
            cars[index].galleryImages.append(imageData)
        }
    }
    
    func deleteGalleryImage(carId: UUID, at index: Int) {
        if let carIndex = cars.firstIndex(where: { $0.id == carId }),
           index >= 0 && index < cars[carIndex].galleryImages.count {
            cars[carIndex].galleryImages.remove(at: index)
        }
    }
    
    // MARK: - Routine Maintenance Tracking
    
    private func updateRoutineMaintenance(for car: inout Car, with log: MaintenanceLog) {
        let service = log.service.lowercased()
        let mileage = log.mileage
        
        if service.contains("oil") && service.contains("change") {
            car.lastOilChangeMileage = mileage
            car.lastOilChangeDate = log.date
        } else if service.contains("tire") && service.contains("rotation") {
            car.lastTireRotationMileage = mileage
            car.lastTireRotationDate = log.date
        } else if service.contains("tire") && (service.contains("replace") || service.contains("new")) {
            car.lastTireReplacementMileage = mileage
            car.lastTireReplacementDate = log.date
        } else if service.contains("brake") && service.contains("inspection") {
            car.lastBrakeInspectionMileage = mileage
            car.lastBrakeInspectionDate = log.date
        }
    }
    
    func getMaintenanceReminders(for car: Car) -> [MaintenanceReminder] {
        var reminders: [MaintenanceReminder] = []
        let currentMileage = car.mileage
        let currentDate = Date()
        
        // Oil Change
        let oilChangeReminder = calculateMaintenanceReminder(
            type: .oilChange,
            lastMileage: car.lastOilChangeMileage,
            lastDate: car.lastOilChangeDate,
            currentMileage: currentMileage,
            currentDate: currentDate
        )
        reminders.append(oilChangeReminder)
        
        // Tire Rotation
        let tireRotationReminder = calculateMaintenanceReminder(
            type: .tireRotation,
            lastMileage: car.lastTireRotationMileage,
            lastDate: car.lastTireRotationDate,
            currentMileage: currentMileage,
            currentDate: currentDate
        )
        reminders.append(tireRotationReminder)
        
        // Tire Replacement
        let tireReplacementReminder = calculateMaintenanceReminder(
            type: .tireReplacement,
            lastMileage: car.lastTireReplacementMileage,
            lastDate: car.lastTireReplacementDate,
            currentMileage: currentMileage,
            currentDate: currentDate
        )
        reminders.append(tireReplacementReminder)
        
        // Brake Inspection
        let brakeInspectionReminder = calculateMaintenanceReminder(
            type: .brakeInspection,
            lastMileage: car.lastBrakeInspectionMileage,
            lastDate: car.lastBrakeInspectionDate,
            currentMileage: currentMileage,
            currentDate: currentDate
        )
        reminders.append(brakeInspectionReminder)
        
        return reminders
    }
    
    private func calculateMaintenanceReminder(
        type: RoutineMaintenanceType,
        lastMileage: Int?,
        lastDate: Date?,
        currentMileage: Int,
        currentDate: Date
    ) -> MaintenanceReminder {
        let mileageInterval = type.recommendedIntervalMiles
        let monthsInterval = type.recommendedIntervalMonths
        
        var milesUntilDue: Int?
        var daysUntilDue: Int?
        var isDue = false
        var isOverdue = false
        
        if let lastMile = lastMileage, let lastDt = lastDate {
            let milesSinceService = currentMileage - lastMile
            let daysSinceService = Calendar.current.dateComponents([.day], from: lastDt, to: currentDate).day ?? 0
            let monthsSinceService = Calendar.current.dateComponents([.month], from: lastDt, to: currentDate).month ?? 0
            
            let mileageRemaining = mileageInterval - milesSinceService
            let daysRemaining = (monthsInterval * 30) - daysSinceService
            
            milesUntilDue = max(0, mileageRemaining)
            daysUntilDue = max(0, daysRemaining)
            
            isDue = mileageRemaining <= 1000 || daysRemaining <= 30
            isOverdue = mileageRemaining < 0 || daysRemaining < 0
        } else {
            // Never serviced - consider overdue
            isOverdue = true
            milesUntilDue = mileageInterval
            daysUntilDue = monthsInterval * 30
        }
        
        return MaintenanceReminder(
            id: UUID(),
            type: type,
            isDue: isDue,
            isOverdue: isOverdue,
            daysUntilDue: daysUntilDue,
            milesUntilDue: milesUntilDue,
            lastServiceDate: lastDate,
            lastServiceMileage: lastMileage
        )
    }
}

