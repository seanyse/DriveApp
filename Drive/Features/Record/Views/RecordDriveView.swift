//
//  RecordDriveView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct RecordDriveView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isRecording = false
    
    var body: some View {
        NavigationStack {
            VStack {
                MapView(region: $locationManager.region)
                    .frame(height: 400)
                
                VStack {
                    Text(String(format: "%.1f mph", locationManager.speed))
                        .font(.system(size: 48))
                        .bold()
                    
                    Button(action: {
                        isRecording.toggle()
                    }) {
                        Text(isRecording ? "Stop Recording" : "Start Recording")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isRecording ? Color.red : Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .padding()
            }
        }
    }
}

#Preview {
    RecordDriveView()
}

