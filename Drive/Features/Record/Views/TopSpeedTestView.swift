//
//  TopSpeedTestView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI
import CoreLocation

struct TopSpeedTestView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isRecording = false
    @State private var maxSpeed: Double = 0.0
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray, lineWidth: 15)
                        .frame(width: 300, height: 300)
                    
                    VStack {
                        Text(String(format: "%.1f", maxSpeed))
                            .font(.system(size: 72))
                            .bold()
                        Text("mph")
                            .font(.title)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack {
                    Text(String(format: "Current: %.1f mph", locationManager.speed))
                        .font(.title2)
                    
                    Button(action: {
                        isRecording.toggle()
                        if !isRecording {
                            maxSpeed = 0.0
                        }
                    }) {
                        Text(isRecording ? "Stop Test" : "Start Test")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isRecording ? Color.red : Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .onChange(of: locationManager.speed) { oldValue, newValue in
                if isRecording {
                    maxSpeed = max(maxSpeed, newValue)
                }
            }
        }
    }
}

#Preview {
    TopSpeedTestView()
}

