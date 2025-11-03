//
//  RecordView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct RecordView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        ZStack {
            // Full screen map
            MapView(region: $locationManager.region)
                .ignoresSafeArea()
            
            VStack {
                // Floating navigation bar
                FloatingNavBar(speed: locationManager.speed)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                Spacer()
                
                // Floating action buttons
                FloatingActionButtons()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
        }
    }
}

// Floating navigation bar
struct FloatingNavBar: View {
    let speed: Double
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Drive")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(String(format: "%.0f mph", speed))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

// Floating action buttons
struct FloatingActionButtons: View {
    var body: some View {
        HStack(spacing: 16) {
            NavigationLink(destination: RecordDriveView()) {
                ActionButton(
                    icon: "car.rear.fill",
                    title: "Record\nDrive",
                    color: .blue
                )
            }
            
            NavigationLink(destination: ZeroSixtyTestView()) {
                ActionButton(
                    icon: "gearshift.layout.sixspeed",
                    title: "0-60\nTest",
                    color: .purple
                )
            }
        }
    }
}

// Reusable action button
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(color.gradient)
                .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
        )
    }
}

struct MapView: View {
    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .none)
    }
}

#Preview {
    RecordView()
}

