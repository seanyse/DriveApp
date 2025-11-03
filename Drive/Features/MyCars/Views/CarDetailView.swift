//
//  CarDetailView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI

struct MaintenanceLog: Identifiable {
    let id = UUID()
    let date: String
    let service: String
    let mileage: Int
    let cost: Double
}

struct ModificationLog: Identifiable {
    let id = UUID()
    let date: String
    let part: String
    let description: String
    let cost: Double
}

struct CarDetailView: View {
    let car: Car
    @State private var selectedTab = 0
    
    private let sampleMaintenance = [
        MaintenanceLog(date: "Jan 15, 2025", service: "Oil Change", mileage: 55500, cost: 45.00),
        MaintenanceLog(date: "Dec 1, 2024", service: "Tire Rotation", mileage: 54500, cost: 30.00),
        MaintenanceLog(date: "Nov 10, 2024", service: "Brake Inspection", mileage: 53500, cost: 50.00)
    ]
    
    private let sampleMods = [
        ModificationLog(date: "Feb 2024", part: "Cold Air Intake", description: "K&N Cold Air Intake System", cost: 350.00),
        ModificationLog(date: "Jan 2024", part: "Exhaust", description: "Borla Cat-Back Exhaust", cost: 1200.00),
        ModificationLog(date: "Dec 2023", part: "ECU Tune", description: "Cobb Accessport Stage 1", cost: 695.00)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CarHeaderView(car: car)
            
            // Tab Selector
            TabSelector(selectedTab: $selectedTab)
            
            // Content
            ScrollView {
                if selectedTab == 0 {
                    OverviewSection(car: car)
                } else if selectedTab == 1 {
                    MaintenanceSection(logs: sampleMaintenance)
                } else {
                    ModificationSection(logs: sampleMods)
                }
            }
            .background(Color(.systemGray6))
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CarHeaderView: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: car.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.blue.gradient)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(car.name)
                        .font(.title)
                        .bold()
                    
                    Text("\(car.year)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(car.horsepower)")
                        .font(.title2)
                        .bold()
                    Text("HP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 16) {
                InfoBadge(icon: "gauge.high", value: "\(car.mileage)", label: "Miles")
                InfoBadge(icon: "calendar", value: "\(car.year)", label: "Year")
                InfoBadge(icon: "speedometer", value: "\(car.horsepower)HP", label: "Power")
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct InfoBadge: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(.blue)
            Text(value)
                .font(.caption)
                .bold()
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

struct TabSelector: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            TabButton(title: "Maintenance", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            TabButton(title: "Mods", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
        }
        .padding(.horizontal)
        .background(Color(.systemBackground))
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .blue : .secondary)
                
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }
}

struct OverviewSection: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Stats")
                .font(.headline)
                .padding(.horizontal)
            
            StatCard(icon: "gauge.high", title: "Total Mileage", value: "\(car.mileage) miles")
            StatCard(icon: "speedometer", title: "Horsepower", value: "\(car.horsepower) HP")
            StatCard(icon: "calendar", title: "Model Year", value: "\(car.year)")
        }
        .padding(.top)
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
        .padding(.horizontal)
    }
}

struct MaintenanceSection: View {
    let logs: [MaintenanceLog]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Service History")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(logs) { log in
                LogCard(
                    icon: "wrench.and.screwdriver.fill",
                    date: log.date,
                    title: log.service,
                    detail: "\(log.mileage) miles",
                    cost: log.cost,
                    color: .blue
                )
            }
        }
        .padding(.top)
    }
}

struct ModificationSection: View {
    let logs: [ModificationLog]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Modifications")
                .font(.headline)
                .padding(.horizontal)
            
            ForEach(logs) { log in
                LogCard(
                    icon: "sparkles",
                    date: log.date,
                    title: log.part,
                    detail: log.description,
                    cost: log.cost,
                    color: .purple
                )
            }
        }
        .padding(.top)
    }
}

struct LogCard: View {
    let icon: String
    let date: String
    let title: String
    let detail: String
    let cost: Double
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("$\(Int(cost))")
                .font(.headline)
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        CarDetailView(car: Car(name: "Honda Pilot", year: 2020, horsepower: 280, imageName: "car.fill", mileage: 56000))
    }
}

