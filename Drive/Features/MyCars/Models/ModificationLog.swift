//
//  ModificationLog.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import Foundation

struct ModificationLog: Identifiable, Codable, Hashable {
    var id: UUID
    var date: Date
    var part: String
    var description: String
    var cost: Double
    var receiptImageData: Data? // Receipt image stored as Data
    
    init(
        id: UUID = UUID(),
        date: Date,
        part: String,
        description: String,
        cost: Double,
        receiptImageData: Data? = nil
    ) {
        self.id = id
        self.date = date
        self.part = part
        self.description = description
        self.cost = cost
        self.receiptImageData = receiptImageData
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

