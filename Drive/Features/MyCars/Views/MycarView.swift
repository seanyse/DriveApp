//
//  MycarView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI

struct Car: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let year: Int
    let horsepower: Int
    let imageName: String // For a car image
    let mileage: Int
    // add service history later
    // add tuning services later
    // add license plate later
    // add vin later
    
}


class MyCarViewModel: ObservableObject {
    @Published var cars: [Car] = [
        Car(name: "Honda Pilot", year: 2020, horsepower: 280, imageName: "car.fill", mileage: 56000),
        Car(name: "Audi S4", year: 2022, horsepower: 349, imageName: "car.fill", mileage: 56000),
        Car(name: "Ford Mustang", year: 2018, horsepower: 460, imageName: "car.fill", mileage: 56000)
    ]
}

struct MycarView: View {
    @StateObject private var viewModel = MyCarViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(viewModel.cars) { car in
                            NavigationLink(destination: CarDetailView(car: car)) {
                                CarRowView(car: car)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("My Cars")
        }
    }
}

struct CarRowView: View {
    let car: Car

    var body: some View {
        HStack(spacing: 16) {
            // Car Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.blue.gradient.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Image(systemName: car.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.blue.gradient)
            }

            // Car Details
            VStack(alignment: .leading, spacing: 8) {
                Text(car.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Label("\(car.year)", systemImage: "calendar")
                    Label("\(car.horsepower) HP", systemImage: "speedometer")
                    Label("\(car.mileage)", systemImage: "gauge.high")
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


#Preview {
    MycarView()
}
