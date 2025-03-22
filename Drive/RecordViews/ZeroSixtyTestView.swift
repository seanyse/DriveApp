//
//  ZeroSixtyTestView.swift
//  Drive
//
//  Created by Sean Yan on 3/9/25.
//

import SwiftUI

struct ZeroSixtyTestView: View {
    @StateObject private var accelerationManager = AccelerationManager()
    @StateObject private var locationManager = LocationManager()
    
    @State private var status: String = "Not Ready"
    @State private var timer: Double = 0.000
    @State private var speed: Double = 0.000
    @State private var acceleration: Double = 0.000


    var body: some View {
        VStack {
            statusView(status: status)
            Spacer()
            zeroSixtyView(timer: timer)
            Spacer()
            HStack {
                speedView()
                accelerationView()
            }
        }
//        Text("0-60!")
//        Text("X: \(accelerationManager.accelerationX, specifier: "%.3f")")
//        Text("Y: \(accelerationManager.accelerationY, specifier: "%.3f")")
//        Text("Z: \(accelerationManager.accelerationZ, specifier: "%.3f")")
//        
//        Button("Stop Updates") {
//            accelerationManager.stopUpdates()
//        }
        
    }
    private func speedView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .frame(width: 170, height: 100)
                .padding(3)
            VStack {
                Text("\(locationManager.speed, specifier: "%.2f") mph")
            }
        }
    }
    private func accelerationView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .frame(width: 170, height: 100)
                .padding(3)
            VStack {
                Text("\(accelerationManager.acc_mag, specifier: "%.2f") g")
            }
        }
    }


}

private func statusView(status: String) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2.0)
            .frame(width: 350, height: 100)
            .padding(3)
        VStack {
            Text(status)
        }
    }
}
private func zeroSixtyView(timer: Double) -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2.0)
            .frame(width: 350, height: 100)
            .padding(3)
        VStack {
            Text("\(timer, specifier: "%.3f") s")
        }
    }
}



#Preview {
    ZeroSixtyTestView()
}
