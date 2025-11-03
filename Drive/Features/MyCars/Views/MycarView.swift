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
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(viewModel.cars) { car in
                        NavigationLink(destination: CarDetailView(car: car)) {
                            CarRowView(car: car)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("My Cars")
            .background(Color(.systemGray6))
        }
    }
}
struct CarRowView: View {
    let car: Car

    var body: some View {
        HStack(spacing: 20) {
            // Car Image
            Image(systemName: car.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .padding()
                .background(Color(.systemGray6))
//                .clipShape(Circle())

            // Car Details
            VStack(alignment: .leading, spacing: 4) {
                Text(car.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Year: \(car.year)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("HP: \(car.horsepower)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Navigation Indicator
            Image(systemName: "chevron.right")
//                .foregroundColor(.gray)
                .imageScale(.medium)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


#Preview {
    MycarView()
}
