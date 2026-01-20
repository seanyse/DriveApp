//
//  DriveSummaryView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI
import MapKit

struct DriveSummaryView: View {
    let drive: DriveData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Route Map
                RouteMapView(coordinates: drive.routeCoordinates.map { $0.coordinate })
                    .frame(height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .padding(.horizontal, 16)
                
                // Main Stats
                MainStatsCard(drive: drive)
                    .padding(.horizontal, 16)
                
                // Speed Stats
                SpeedStatsCard(drive: drive)
                    .padding(.horizontal, 16)
                
                // Elevation Stats
                ElevationStatsCard(drive: drive)
                    .padding(.horizontal, 16)
                
                // Speed Chart
                if !drive.speedSamples.isEmpty {
                    SpeedChartCard(samples: drive.speedSamples)
                        .padding(.horizontal, 16)
                }
                
                // Elevation Chart
                if !drive.elevationSamples.isEmpty {
                    ElevationChartCard(samples: drive.elevationSamples)
                        .padding(.horizontal, 16)
                }
                
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Drive Summary")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                ShareLink(item: generateShareText()) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    private func generateShareText() -> String {
        """
        🚗 Drive Summary
        
        📍 Distance: \(String(format: "%.2f", drive.distance)) mi
        ⏱ Duration: \(formatDuration(drive.duration))
        🏎 Top Speed: \(String(format: "%.1f", drive.topSpeed)) mph
        📊 Avg Speed: \(String(format: "%.1f", drive.averageSpeed)) mph
        ⚡️ Max Acceleration: \(String(format: "%.1f", drive.greatestAcceleration)) mph/s
        ⛰ Elevation Gain: \(String(format: "%.0f", drive.elevationGain)) ft
        """
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        }
        return String(format: "%dm %ds", minutes, seconds)
    }
}

// MARK: - Route Map

struct RouteMapView: View {
    let coordinates: [CLLocationCoordinate2D]
    
    var body: some View {
        Map {
            if !coordinates.isEmpty {
                MapPolyline(coordinates: coordinates)
                    .stroke(.blue, lineWidth: 4)
                
                // Start marker
                if let first = coordinates.first {
                    Annotation("Start", coordinate: first) {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                }
                
                // End marker
                if let last = coordinates.last, coordinates.count > 1 {
                    Annotation("End", coordinate: last) {
                        Circle()
                            .fill(.red)
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            )
                    }
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic))
    }
}

// MARK: - Main Stats Card

struct MainStatsCard: View {
    let drive: DriveData
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                MainStatItem(
                    icon: "road.lanes",
                    value: String(format: "%.2f", drive.distance),
                    unit: "miles",
                    color: .blue
                )
                
                MainStatItem(
                    icon: "clock.fill",
                    value: formatDuration(drive.duration),
                    unit: "duration",
                    color: .orange
                )
            }
        }
        .padding(20)
        .glassBackground(cornerRadius: 24)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MainStatItem: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(unit.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Speed Stats Card

struct SpeedStatsCard: View {
    let drive: DriveData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Speed", systemImage: "speedometer")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                StatTile(
                    title: "Top Speed",
                    value: String(format: "%.1f", drive.topSpeed),
                    unit: "mph",
                    icon: "arrow.up",
                    color: .red
                )
                
                StatTile(
                    title: "Average",
                    value: String(format: "%.1f", drive.averageSpeed),
                    unit: "mph",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                )
                
                StatTile(
                    title: "Max Accel",
                    value: String(format: "%.1f", drive.greatestAcceleration),
                    unit: "mph/s",
                    icon: "bolt.fill",
                    color: .yellow
                )
            }
        }
        .padding(20)
        .glassBackground(cornerRadius: 24)
    }
}

// MARK: - Elevation Stats Card

struct ElevationStatsCard: View {
    let drive: DriveData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Elevation", systemImage: "mountain.2.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                StatTile(
                    title: "Gain",
                    value: String(format: "%.0f", drive.elevationGain),
                    unit: "ft",
                    icon: "arrow.up.right",
                    color: .green
                )
                
                StatTile(
                    title: "Loss",
                    value: String(format: "%.0f", drive.elevationLoss),
                    unit: "ft",
                    icon: "arrow.down.right",
                    color: .red
                )
                
                StatTile(
                    title: "Max",
                    value: String(format: "%.0f", drive.maxElevation),
                    unit: "ft",
                    icon: "mountain.2.fill",
                    color: .purple
                )
            }
        }
        .padding(20)
        .glassBackground(cornerRadius: 24)
    }
}

// MARK: - Stat Tile

struct StatTile: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text(unit)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Speed Chart Card

struct SpeedChartCard: View {
    let samples: [DriveData.SpeedSample]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Speed Over Time", systemImage: "chart.xyaxis.line")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            
            SpeedChartView(samples: samples)
                .frame(height: 150)
        }
        .padding(20)
        .glassBackground(cornerRadius: 24)
    }
}

struct SpeedChartView: View {
    let samples: [DriveData.SpeedSample]
    
    private var maxSpeed: Double {
        samples.map(\.speed).max() ?? 1
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Grid lines
                VStack(spacing: height / 4) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 1)
                    }
                }
                
                // Line chart
                if samples.count > 1 {
                    Path { path in
                        let maxTime = samples.last?.timestamp ?? 1
                        
                        for (index, sample) in samples.enumerated() {
                            let x = (sample.timestamp / maxTime) * width
                            let y = height - (sample.speed / maxSpeed) * height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
                    )
                    
                    // Gradient fill
                    Path { path in
                        let maxTime = samples.last?.timestamp ?? 1
                        
                        path.move(to: CGPoint(x: 0, y: height))
                        
                        for sample in samples {
                            let x = (sample.timestamp / maxTime) * width
                            let y = height - (sample.speed / maxSpeed) * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Elevation Chart Card

struct ElevationChartCard: View {
    let samples: [DriveData.ElevationSample]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Elevation Profile", systemImage: "waveform.path.ecg")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
            
            ElevationChartView(samples: samples)
                .frame(height: 150)
        }
        .padding(20)
        .glassBackground(cornerRadius: 24)
    }
}

struct ElevationChartView: View {
    let samples: [DriveData.ElevationSample]
    
    private var minElevation: Double {
        samples.map(\.elevation).min() ?? 0
    }
    
    private var maxElevation: Double {
        samples.map(\.elevation).max() ?? 1
    }
    
    private var elevationRange: Double {
        max(maxElevation - minElevation, 1)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                // Grid lines
                VStack(spacing: height / 4) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(height: 1)
                    }
                }
                
                // Area chart
                if samples.count > 1 {
                    Path { path in
                        let maxTime = samples.last?.timestamp ?? 1
                        
                        path.move(to: CGPoint(x: 0, y: height))
                        
                        for sample in samples {
                            let x = (sample.timestamp / maxTime) * width
                            let normalizedElevation = (sample.elevation - minElevation) / elevationRange
                            let y = height - normalizedElevation * height
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.closeSubpath()
                    }
                    .fill(
                        LinearGradient(
                            colors: [.green.opacity(0.6), .green.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Line
                    Path { path in
                        let maxTime = samples.last?.timestamp ?? 1
                        
                        for (index, sample) in samples.enumerated() {
                            let x = (sample.timestamp / maxTime) * width
                            let normalizedElevation = (sample.elevation - minElevation) / elevationRange
                            let y = height - normalizedElevation * height
                            
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DriveSummaryView(drive: DriveData(
            id: UUID(),
            date: Date(),
            duration: 1847,
            distance: 12.45,
            topSpeed: 78.5,
            averageSpeed: 42.3,
            greatestAcceleration: 8.2,
            elevationGain: 342,
            elevationLoss: 298,
            minElevation: 245,
            maxElevation: 587,
            routeCoordinates: [],
            speedSamples: (0..<100).map { i in
                DriveData.SpeedSample(speed: Double.random(in: 20...70), timestamp: Double(i) * 18.47)
            },
            elevationSamples: (0..<100).map { i in
                DriveData.ElevationSample(elevation: 300 + sin(Double(i) * 0.1) * 100, timestamp: Double(i) * 18.47)
            }
        ))
    }
}
