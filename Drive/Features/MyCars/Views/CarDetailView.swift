//
//  CarDetailView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct CarDetailView: View {
    @ObservedObject var viewModel: CarViewModel
    let car: Car
    
    @State private var selectedTab = 0
    @State private var showEditStats = false
    @State private var showAddMaintenance = false
    @State private var showAddMod = false
    @State private var editingMaintenance: MaintenanceLog?
    @State private var editingMod: ModificationLog?
    
    private var carBinding: Binding<Car> {
        Binding(
            get: { viewModel.getCar(by: car.id) ?? car },
            set: { viewModel.updateCar($0) }
        )
    }
    
    private var currentCar: Car {
        viewModel.getCar(by: car.id) ?? car
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CarHeaderView(car: currentCar)
            
            // Tab Selector
            TabSelector(selectedTab: $selectedTab, tabCount: 4)
            
            // Content
            ScrollView {
                if selectedTab == 0 {
                    OverviewSection(car: currentCar, viewModel: viewModel, showEditStats: $showEditStats)
                } else if selectedTab == 1 {
                    MaintenanceSection(
                        car: currentCar,
                        viewModel: viewModel,
                        showAddMaintenance: $showAddMaintenance,
                        editingMaintenance: $editingMaintenance
                    )
                } else if selectedTab == 2 {
                    ModificationSection(
                        car: currentCar,
                        viewModel: viewModel,
                        showAddMod: $showAddMod,
                        editingMod: $editingMod
                    )
                } else {
                    PicturesSection(car: currentCar, viewModel: viewModel)
                }
            }
            .background(Color(.systemGray6))
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showEditStats = true
                }) {
                    Image(systemName: "pencil")
                }
            }
        }
        .sheet(isPresented: $showEditStats) {
            EditStatsSheet(car: currentCar, viewModel: viewModel, showSheet: $showEditStats)
        }
        .sheet(isPresented: $showAddMaintenance) {
            AddEditMaintenanceSheet(
                car: currentCar,
                viewModel: viewModel,
                showSheet: $showAddMaintenance,
                log: nil
            )
        }
        .sheet(item: $editingMaintenance) { log in
            AddEditMaintenanceSheet(
                car: currentCar,
                viewModel: viewModel,
                showSheet: Binding(
                    get: { editingMaintenance != nil },
                    set: { if !$0 { editingMaintenance = nil } }
                ),
                log: log
            )
        }
        .sheet(isPresented: $showAddMod) {
            AddEditModificationSheet(
                car: currentCar,
                viewModel: viewModel,
                showSheet: $showAddMod,
                log: nil
            )
        }
        .sheet(item: $editingMod) { log in
            AddEditModificationSheet(
                car: currentCar,
                viewModel: viewModel,
                showSheet: Binding(
                    get: { editingMod != nil },
                    set: { if !$0 { editingMod = nil } }
                ),
                log: log
            )
        }
    }
}

struct CarHeaderView: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                if let imageData = car.mainImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "car.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.blue.gradient)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(car.displayName)
                        .font(.title)
                        .bold()
                    
                    if let color = car.color {
                        Text(color)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
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
    let tabCount: Int
    
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
            TabButton(title: "Pictures", isSelected: selectedTab == 3) {
                selectedTab = 3
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
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
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
    @ObservedObject var viewModel: CarViewModel
    @Binding var showEditStats: Bool
    
    var reminders: [MaintenanceReminder] {
        viewModel.getMaintenanceReminders(for: car)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Service Summary
            ServiceSummaryCard(car: car)
            
            // Routine Maintenance Reminders
            if !reminders.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Maintenance Reminders")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(reminders) { reminder in
                        MaintenanceReminderCard(reminder: reminder)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            
            // Quick Stats
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Stats")
                    .font(.headline)
                    .padding(.horizontal)
                
                if let torque = car.torque {
                    StatCard(icon: "gauge.high", title: "Torque", value: "\(torque) lb-ft")
                }
                if let engine = car.engine {
                    StatCard(icon: "engine.fill", title: "Engine", value: engine)
                }
                if let transmission = car.transmission {
                    StatCard(icon: "gearshift", title: "Transmission", value: transmission)
                }
                if let drivetrain = car.drivetrain {
                    StatCard(icon: "car.front.waves.up", title: "Drivetrain", value: drivetrain)
                }
                StatCard(icon: "gauge.high", title: "Total Mileage", value: "\(car.mileage) miles")
                StatCard(icon: "speedometer", title: "Horsepower", value: "\(car.horsepower) HP")
            }
            .padding(.top)
        }
        .padding(.vertical)
    }
}

struct ServiceSummaryCard: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Service Summary")
                .font(.headline)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Total Spent")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(car.totalServiceCost, specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Maintenance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(car.totalMaintenanceCost, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Modifications")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(car.totalModificationCost, specifier: "%.2f")")
                            .font(.headline)
                            .foregroundColor(.purple)
                    }
                }
            }
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

struct MaintenanceReminderCard: View {
    let reminder: MaintenanceReminder
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(reminder.urgencyColor)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.type.rawValue)
                    .font(.headline)
                
                if let milesUntilDue = reminder.milesUntilDue {
                    Text("\(milesUntilDue) miles until due")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                if let daysUntilDue = reminder.daysUntilDue {
                    Text("\(daysUntilDue) days until due")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if reminder.isOverdue {
                    Text("OVERDUE")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.red)
                } else if reminder.isDue {
                    Text("Due Soon")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.orange)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
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

struct PicturesSection: View {
    let car: Car
    @ObservedObject var viewModel: CarViewModel
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Get the current car from viewModel to ensure reactivity
    private var currentCar: Car {
        viewModel.getCar(by: car.id) ?? car
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Gallery")
                    .font(.headline)
                Spacer()
                PhotosPicker(selection: $selectedImage, matching: .images) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if currentCar.galleryImages.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No photos yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + to add photos from your camera roll")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(Array(currentCar.galleryImages.enumerated()), id: \.offset) { index, imageData in
                        if let uiImage = UIImage(data: imageData) {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                
                                Button(action: {
                                    viewModel.deleteGalleryImage(carId: currentCar.id, at: index)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                        .padding(8)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .onChange(of: selectedImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        viewModel.addGalleryImage(to: currentCar.id, imageData: data)
                        selectedImage = nil // Reset picker
                    }
                }
            }
        }
    }
}

struct MaintenanceSection: View {
    let car: Car
    @ObservedObject var viewModel: CarViewModel
    @Binding var showAddMaintenance: Bool
    @Binding var editingMaintenance: MaintenanceLog?
    
    var sortedLogs: [MaintenanceLog] {
        car.maintenanceLogs.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Service History")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showAddMaintenance = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if sortedLogs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "wrench.and.screwdriver")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No maintenance logs yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + to add your first maintenance record")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(sortedLogs) { log in
                    MaintenanceLogCard(
                        log: log,
                        onEdit: {
                            editingMaintenance = log
                        },
                        onDelete: {
                            viewModel.deleteMaintenanceLog(carId: car.id, logId: log.id)
                        }
                    )
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

struct MaintenanceLogCard: View {
    let log: MaintenanceLog
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.service)
                        .font(.headline)
                    Text(log.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(log.mileage) miles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if let description = log.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("$\(log.cost, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.blue)
                    
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let receiptData = log.receiptImageData,
               let uiImage = UIImage(data: receiptData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
}

struct ModificationSection: View {
    let car: Car
    @ObservedObject var viewModel: CarViewModel
    @Binding var showAddMod: Bool
    @Binding var editingMod: ModificationLog?
    
    var sortedLogs: [ModificationLog] {
        car.modificationLogs.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Modifications")
                    .font(.headline)
                Spacer()
                Button(action: {
                    showAddMod = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            
            if sortedLogs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No modifications yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + to add your first modification")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 60)
            } else {
                ForEach(sortedLogs) { log in
                    ModificationLogCard(
                        log: log,
                        onEdit: {
                            editingMod = log
                        },
                        onDelete: {
                            viewModel.deleteModificationLog(carId: car.id, logId: log.id)
                        }
                    )
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
}

struct ModificationLogCard: View {
    let log: ModificationLog
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.purple)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(log.part)
                        .font(.headline)
                    Text(log.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(log.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("$\(log.cost, specifier: "%.2f")")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            if let receiptData = log.receiptImageData,
               let uiImage = UIImage(data: receiptData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
}

// MARK: - Edit Stats Sheet

struct EditStatsSheet: View {
    let car: Car
    @ObservedObject var viewModel: CarViewModel
    @Binding var showSheet: Bool
    
    @State private var mileage: String
    @State private var horsepower: String
    @State private var torque: String
    
    init(car: Car, viewModel: CarViewModel, showSheet: Binding<Bool>) {
        self.car = car
        self.viewModel = viewModel
        _showSheet = showSheet
        _mileage = State(initialValue: "\(car.mileage)")
        _horsepower = State(initialValue: "\(car.horsepower)")
        _torque = State(initialValue: car.torque.map { "\($0)" } ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Car Stats")) {
                    TextField("Current Mileage", text: $mileage)
                        .keyboardType(.numberPad)
                    TextField("Horsepower", text: $horsepower)
                        .keyboardType(.numberPad)
                    TextField("Torque (lb-ft)", text: $torque)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Edit Stats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveStats()
                    }
                }
            }
        }
    }
    
    private func saveStats() {
        var updatedCar = car
        updatedCar.mileage = Int(mileage) ?? car.mileage
        updatedCar.horsepower = Int(horsepower) ?? car.horsepower
        updatedCar.torque = Int(torque)
        viewModel.updateCar(updatedCar)
        showSheet = false
    }
}

// MARK: - Add/Edit Maintenance Sheet

struct AddEditMaintenanceSheet: View {
    let car: Car
    @ObservedObject var viewModel: CarViewModel
    @Binding var showSheet: Bool
    let log: MaintenanceLog?
    
    @State private var selectedServiceType: MaintenanceServiceType = .oilChange
    @State private var customService = ""
    @State private var date = Date()
    @State private var mileage = ""
    @State private var cost = ""
    @State private var description = ""
    @State private var selectedReceipt: PhotosPickerItem?
    @State private var receiptImage: UIImage?
    
    var isEditing: Bool {
        log != nil
    }
    
    var serviceText: String {
        selectedServiceType.isOther ? customService : selectedServiceType.rawValue
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Service Information")) {
                    Picker("Service Type", selection: $selectedServiceType) {
                        ForEach(MaintenanceServiceType.allCases, id: \.self) { serviceType in
                            Text(serviceType.rawValue).tag(serviceType)
                        }
                    }
                    
                    if selectedServiceType.isOther {
                        TextField("Enter service type", text: $customService)
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Mileage", text: $mileage)
                        .keyboardType(.numberPad)
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                    TextField("Description (Optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Receipt Photo")) {
                    PhotosPicker(selection: $selectedReceipt, matching: .images) {
                        HStack {
                            if let receiptImage = receiptImage {
                                Image(uiImage: receiptImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Text(receiptImage != nil ? "Change Receipt" : "Select Receipt")
                                .foregroundColor(.blue)
                        }
                    }
                    .onChange(of: selectedReceipt) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    receiptImage = uiImage
                                }
                            }
                        }
                    }
                    
                    if receiptImage != nil {
                        Button(role: .destructive, action: {
                            receiptImage = nil
                            selectedReceipt = nil
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove Receipt")
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Maintenance" : "Add Maintenance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveMaintenance()
                    }
                    .disabled(serviceText.isEmpty || mileage.isEmpty || cost.isEmpty)
                }
            }
            .onAppear {
                if let log = log {
                    loadLogData(log)
                }
            }
        }
    }
    
    private func loadLogData(_ log: MaintenanceLog) {
        // Check if the service matches a known type
        if let matchingType = MaintenanceServiceType.allCases.first(where: { $0.rawValue == log.service }) {
            selectedServiceType = matchingType
            customService = ""
        } else {
            selectedServiceType = .other
            customService = log.service
        }
        
        date = log.date
        mileage = "\(log.mileage)"
        cost = "\(log.cost)"
        description = log.description ?? ""
        
        if let receiptData = log.receiptImageData {
            receiptImage = UIImage(data: receiptData)
        }
    }
    
    private func saveMaintenance() {
        let mileageInt = Int(mileage) ?? 0
        let costDouble = Double(cost) ?? 0.0
        
        let updatedLog = MaintenanceLog(
            id: log?.id ?? UUID(),
            date: date,
            service: serviceText,
            mileage: mileageInt,
            cost: costDouble,
            description: description.isEmpty ? nil : description,
            receiptImageData: receiptImage?.jpegData(compressionQuality: 0.8)
        )
        
        if isEditing {
            viewModel.updateMaintenanceLog(carId: car.id, logId: log!.id, updatedLog: updatedLog)
        } else {
            viewModel.addMaintenanceLog(to: car.id, log: updatedLog)
        }
        
        showSheet = false
    }
}

// MARK: - Add/Edit Modification Sheet

struct AddEditModificationSheet: View {
    let car: Car
    @ObservedObject var viewModel: CarViewModel
    @Binding var showSheet: Bool
    let log: ModificationLog?
    
    @State private var part = ""
    @State private var description = ""
    @State private var date = Date()
    @State private var cost = ""
    @State private var selectedReceipt: PhotosPickerItem?
    @State private var receiptImage: UIImage?
    
    var isEditing: Bool {
        log != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Modification Information")) {
                    TextField("Part Name", text: $part)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                }
                
                Section(header: Text("Receipt Photo")) {
                    PhotosPicker(selection: $selectedReceipt, matching: .images) {
                        HStack {
                            if let receiptImage = receiptImage {
                                Image(uiImage: receiptImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Text(receiptImage != nil ? "Change Receipt" : "Select Receipt")
                                .foregroundColor(.blue)
                        }
                    }
                    .onChange(of: selectedReceipt) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    receiptImage = uiImage
                                }
                            }
                        }
                    }
                    
                    if receiptImage != nil {
                        Button(role: .destructive, action: {
                            receiptImage = nil
                            selectedReceipt = nil
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove Receipt")
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Modification" : "Add Modification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveModification()
                    }
                    .disabled(part.isEmpty || description.isEmpty || cost.isEmpty)
                }
            }
            .onAppear {
                if let log = log {
                    loadLogData(log)
                }
            }
        }
    }
    
    private func loadLogData(_ log: ModificationLog) {
        part = log.part
        description = log.description
        date = log.date
        cost = "\(log.cost)"
        
        if let receiptData = log.receiptImageData {
            receiptImage = UIImage(data: receiptData)
        }
    }
    
    private func saveModification() {
        let costDouble = Double(cost) ?? 0.0
        
        let updatedLog = ModificationLog(
            id: log?.id ?? UUID(),
            date: date,
            part: part,
            description: description,
            cost: costDouble,
            receiptImageData: receiptImage?.jpegData(compressionQuality: 0.8)
        )
        
        if isEditing {
            viewModel.updateModificationLog(carId: car.id, logId: log!.id, updatedLog: updatedLog)
        } else {
            viewModel.addModificationLog(to: car.id, log: updatedLog)
        }
        
        showSheet = false
    }
}

#Preview {
    NavigationStack {
        CarDetailView(
            viewModel: CarViewModel(),
            car: Car(make: "Honda", model: "Pilot", year: 2020, horsepower: 280, mileage: 56000)
        )
    }
}
