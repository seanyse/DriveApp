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
    @StateObject private var recordingManager = RecordingManager()
    @State private var mapType: MKMapType = .standard
    @State private var userTrackingMode: MapUserTrackingMode = .follow
    @State private var showingSummary = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                MapView(
                    region: $locationManager.region,
                    mapType: $mapType,
                    userTrackingMode: $userTrackingMode
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer()
                    
                    StatsOverlay(recordingManager: recordingManager)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                    
                    FloatingActionButtons(recordingManager: recordingManager)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 40)
                }
                
                VStack {
                    HStack {
                        Spacer()
                        MapControlButtons(
                            mapType: $mapType,
                            onRecenter: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    userTrackingMode = .follow
                                }
                            }
                        )
                    }
                    .padding(.top, 60)
                    .padding(.trailing, 16)
                    
                    Spacer()
                }
            }
            .navigationDestination(isPresented: $showingSummary) {
                if let drive = recordingManager.completedDrive {
                    DriveSummaryView(drive: drive)
                }
            }
        }
        .onReceive(locationManager.$location) { location in
            if let location = location {
                recordingManager.updateLocation(location)
            }
        }
        .onChange(of: recordingManager.completedDrive) { _, newValue in
            if newValue != nil {
                showingSummary = true
            }
        }
        .onDisappear {
            recordingManager.stopRecording()
        }
    }
}



// MARK: - Glass Background Modifier

struct GlassBackground: ViewModifier {
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.25),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassBackground(cornerRadius: cornerRadius))
    }
}

// MARK: - Stats Overlay

struct StatsOverlay: View {
    @ObservedObject var recordingManager: RecordingManager
    
    var body: some View {
        HStack(spacing: 0) {
            StatItem(
                value: recordingManager.formattedTime,
                label: "TIME",
                icon: "clock.fill"
            )
            
            StatDivider()
            
            StatItem(
                value: recordingManager.formattedSpeed,
                label: "MPH",
                icon: "speedometer"
            )
            
            StatDivider()
            
            StatItem(
                value: recordingManager.formattedDistance,
                label: "MILES",
                icon: "road.lanes"
            )
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 8)
        .glassBackground(cornerRadius: 28)
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.tertiary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.primary.opacity(0),
                        Color.primary.opacity(0.15),
                        Color.primary.opacity(0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: 1, height: 50)
    }
}

// MARK: - Map Controls

struct MapControlButtons: View {
    @Binding var mapType: MKMapType
    let onRecenter: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            MapControlButton(
                icon: "location.fill",
                action: onRecenter
            )
            
            MapControlButton(
                icon: mapType == .standard ? "globe.americas.fill" : "map.fill",
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        mapType = mapType == .standard ? .hybrid : .standard
                    }
                }
            )
        }
        .padding(8)
        .glassBackground(cornerRadius: 20)
    }
}

struct MapControlButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .fill(Color.primary.opacity(0.08))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Floating Action Buttons

struct FloatingActionButtons: View {
    @ObservedObject var recordingManager: RecordingManager
    
    var body: some View {
        HStack(spacing: 16) {
            // 0-60 Test
            NavigationLink(destination: ZeroSixtyTestView()) {
                SideActionButton(
                    icon: "gauge.with.needle.fill",
                    title: "0-60"
                )
            }
            .buttonStyle(.plain)
            
            // Main Record Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    recordingManager.toggleRecording()
                }
            }) {
                MainActionButton(isRecording: recordingManager.isRecording)
            }
            .buttonStyle(.plain)
            
            // Placeholder
            Button(action: {}) {
                SideActionButton(
                    icon: "ellipsis",
                    title: "More"
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 65)
        .glassBackground(cornerRadius: 32)
    }
}

struct MainActionButton: View {
    let isRecording: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                // Outer glow when recording
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                (isRecording ? Color.red : Color.clear).opacity(0.3),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 50
                        )
                    )
                    .frame(width: 100, height: 100)
                
                // Main button
                Circle()
                    .fill(
                        LinearGradient(
                            colors: isRecording
                                ? [Color.gray.opacity(0.9), Color.gray.opacity(0.7)]
                                : [Color.red, Color.red.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .shadow(color: (isRecording ? Color.gray : Color.red).opacity(0.4), radius: 12, x: 0, y: 6)
                
                // Inner ring
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 3)
                    .frame(width: 58, height: 58)
                
                // Icon
                Group {
                    if isRecording {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                    } else {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 22, height: 22)
                    }
                }
            }
            
            Text(isRecording ? "Stop" : "Record")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
        .scaleEffect(isRecording ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isRecording)
    }
}

struct SideActionButton: View {
    let icon: String
    let title: String
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color.white.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.black.opacity(0.8), Color.black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Map View

struct MapView: View {
    @Binding var region: MKCoordinateRegion
    @Binding var mapType: MKMapType
    @Binding var userTrackingMode: MapUserTrackingMode
    
    var body: some View {
        Map(coordinateRegion: $region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $userTrackingMode)
        .mapStyle(mapType == .standard ? .standard : .hybrid)
    }
}

// MARK: - Preview

#Preview {
    RecordView()
}
