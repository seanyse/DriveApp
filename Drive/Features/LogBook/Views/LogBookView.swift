//
//  LogBookView.swift
//  Drive
//
//  Created by Sean Yan on 3/11/25.
//

import SwiftUI

struct LogBookView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Stats
                        StatsGridView()
                        
                        // Header
                        HStack {
                            Text("Recent Drives")
                                .font(.title2)
                                .bold()
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        // Drive cards
                        DriveCardView(date: "Dec 13", route: "Roswell Road", distance: "25 miles", duration: "30 mins")
                        DriveCardView(date: "Dec 10", route: "Highway 400", distance: "50 miles", duration: "45 mins")
                        DriveCardView(date: "Dec 5", route: "Downtown Loop", distance: "15 miles", duration: "25 mins")
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Logbook")
        }
    }
}

struct StatsGridView: View {
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                LogbookStatCard(icon: "clock.fill", value: "13", label: "Hours", color: .orange)
                LogbookStatCard(icon: "speedometer", value: "120", label: "Top Speed", color: .red)
            }
            
            HStack(spacing: 12) {
                LogbookStatCard(icon: "gauge.high", value: "1,256", label: "Miles", color: .blue)
                LogbookStatCard(icon: "car.fill", value: "42", label: "Drives", color: .green)
            }
        }
        .padding(.horizontal)
    }
}

struct LogbookStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .bold()
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
    }
}

struct DriveCardView: View {
    let date: String
    let route: String
    let distance: String
    let duration: String
    
    var body: some View {
        HStack {
            // Date indicator
            VStack(spacing: 4) {
                Text(date.components(separatedBy: " ").first ?? "")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(date.components(separatedBy: " ").last ?? "")
                    .font(.title2)
                    .bold()
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(route)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    Label(distance, systemImage: "gauge.high")
                    Label(duration, systemImage: "clock.fill")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .imageScale(.small)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8)
        )
        .padding(.horizontal)
    }
}
#Preview {
    LogBookView()
}

