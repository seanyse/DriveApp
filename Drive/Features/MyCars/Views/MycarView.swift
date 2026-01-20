//
//  MycarView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct MycarView: View {
    @StateObject private var viewModel = CarViewModel()
    @State private var showAddCar: Bool = false
    @State private var editingCar: Car?
    @State private var carToDelete: Car?
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                if viewModel.cars.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "car.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary)
                        Text("No cars in your garage")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Tap + to add your first car")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.cars) { car in
                                NavigationLink {
                                    CarDetailView(viewModel: viewModel, car: car)
                                } label: {
                                    CarRowView(car: car)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contentShape(Rectangle())
                                .contextMenu {
                                    Button(action: {
                                        editingCar = car
                                    }) {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive, action: {
                                        carToDelete = car
                                        showDeleteConfirmation = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                        .padding(.bottom, 80) // Add padding for floating button
                    }
                }
                
                // Floating Add Button - positioned to not interfere with car rows
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showAddCar = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color.blue.gradient)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.trailing)
                    .padding(.bottom)
                }
                .allowsHitTesting(true)
            }
            .navigationTitle("My Cars")
        }
        .sheet(isPresented: $showAddCar) {
            AddEditCarSheet(
                showSheet: $showAddCar,
                viewModel: viewModel,
                car: nil
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $editingCar) { car in
            AddEditCarSheet(
                showSheet: Binding(
                    get: { editingCar != nil },
                    set: { if !$0 { editingCar = nil } }
                ),
                viewModel: viewModel,
                car: car
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .alert("Delete Car", isPresented: $showDeleteConfirmation, presenting: carToDelete) { car in
            Button("Cancel", role: .cancel) {
                carToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let carToDelete = carToDelete {
                    viewModel.deleteCar(carToDelete)
                }
                carToDelete = nil
            }
        } message: { car in
            Text("Are you sure you want to delete \(car.displayName)? This action cannot be undone.")
        }
    }
}

struct CarRowView: View {
    let car: Car
    
    var body: some View {
        HStack(spacing: 16) {
            // Car Image or Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue.gradient.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                if let imageData = car.mainImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Image(systemName: "car.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.blue.gradient)
                }
            }
            
            // Car Details
            VStack(alignment: .leading, spacing: 8) {
                Text(car.displayName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Label("\(car.year)", systemImage: "calendar")
                    Label("\(car.horsepower) HP", systemImage: "speedometer")
                    Label("\(car.mileage) mi", systemImage: "gauge.high")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Navigation Indicator
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .imageScale(.small)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct AddEditCarSheet: View {
    @Binding var showSheet: Bool
    @ObservedObject var viewModel: CarViewModel
    let car: Car?
    
    @State private var carMake = ""
    @State private var carModel = ""
    @State private var carYear = ""
    @State private var carHorsepower = ""
    @State private var carMileage = ""
    @State private var carLicensePlate = ""
    @State private var carVin = ""
    @State private var carTorque = ""
    @State private var carEngine = ""
    @State private var carTransmission = ""
    @State private var carDrivetrain = ""
    @State private var carColor = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var carImage: UIImage?
    
    var isEditing: Bool {
        car != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Information")) {
                    TextField("Make", text: $carMake)
                    TextField("Model", text: $carModel)
                    TextField("Year", text: $carYear)
                        .keyboardType(.numberPad)
                    TextField("Current Mileage", text: $carMileage)
                        .keyboardType(.numberPad)
                    TextField("Horsepower", text: $carHorsepower)
                        .keyboardType(.numberPad)
                }
                
                Section(header: Text("Additional Information")) {
                    TextField("License Plate", text: $carLicensePlate)
                    TextField("VIN", text: $carVin)
                    TextField("Torque (lb-ft)", text: $carTorque)
                        .keyboardType(.numberPad)
                    TextField("Engine", text: $carEngine)
                    TextField("Transmission", text: $carTransmission)
                    TextField("Drivetrain", text: $carDrivetrain)
                    TextField("Color", text: $carColor)
                }
                
                Section(header: Text("Car Photo")) {
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        HStack {
                            if let carImage = carImage {
                                Image(uiImage: carImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            } else {
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            Text(carImage != nil ? "Change Photo" : "Select Photo")
                                .foregroundColor(.blue)
                        }
                    }
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) {
                                await MainActor.run {
                                    carImage = uiImage
                                }
                            }
                        }
                    }
                    
                    if carImage != nil {
                        Button(role: .destructive, action: {
                            carImage = nil
                            selectedImage = nil
                        }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove Photo")
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Car" : "Add Car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveCar()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onAppear {
                if let car = car {
                    loadCarData(car)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !carMake.isEmpty && !carModel.isEmpty && !carYear.isEmpty
    }
    
    private func loadCarData(_ car: Car) {
        carMake = car.make
        carModel = car.model
        carYear = "\(car.year)"
        carHorsepower = "\(car.horsepower)"
        carMileage = "\(car.mileage)"
        carLicensePlate = car.licensePlate ?? ""
        carVin = car.vin ?? ""
        carTorque = car.torque.map { "\($0)" } ?? ""
        carEngine = car.engine ?? ""
        carTransmission = car.transmission ?? ""
        carDrivetrain = car.drivetrain ?? ""
        carColor = car.color ?? ""
        
        if let imageData = car.mainImageData {
            carImage = UIImage(data: imageData)
        }
    }
    
    private func saveCar() {
        let yearInt = Int(carYear) ?? 0
        let horsepowerInt = Int(carHorsepower) ?? 0
        let mileageInt = Int(carMileage) ?? 0
        let torqueInt = Int(carTorque)
        
        var updatedCar: Car
        
        if let existingCar = car {
            // Update existing car
            updatedCar = Car(
                id: existingCar.id,
                make: carMake,
                model: carModel,
                year: yearInt,
                horsepower: horsepowerInt,
                mileage: mileageInt,
                licensePlate: carLicensePlate.isEmpty ? nil : carLicensePlate,
                vin: carVin.isEmpty ? nil : carVin,
                mainImageData: carImage?.jpegData(compressionQuality: 0.8),
                torque: torqueInt,
                engine: carEngine.isEmpty ? nil : carEngine,
                transmission: carTransmission.isEmpty ? nil : carTransmission,
                drivetrain: carDrivetrain.isEmpty ? nil : carDrivetrain,
                color: carColor.isEmpty ? nil : carColor,
                galleryImages: existingCar.galleryImages,
                maintenanceLogs: existingCar.maintenanceLogs,
                modificationLogs: existingCar.modificationLogs
            )
            viewModel.updateCar(updatedCar)
        } else {
            // Create new car
            updatedCar = Car(
                make: carMake,
                model: carModel,
                year: yearInt,
                horsepower: horsepowerInt,
                mileage: mileageInt,
                licensePlate: carLicensePlate.isEmpty ? nil : carLicensePlate,
                vin: carVin.isEmpty ? nil : carVin,
                mainImageData: carImage?.jpegData(compressionQuality: 0.8),
                torque: torqueInt,
                engine: carEngine.isEmpty ? nil : carEngine,
                transmission: carTransmission.isEmpty ? nil : carTransmission,
                drivetrain: carDrivetrain.isEmpty ? nil : carDrivetrain,
                color: carColor.isEmpty ? nil : carColor
            )
            viewModel.addCar(updatedCar)
        }
        
        showSheet = false
    }
}

#Preview {
    MycarView()
}
