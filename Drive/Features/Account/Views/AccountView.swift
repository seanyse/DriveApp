//
//  AccountView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Card
                    ProfileCard()
                    
                    // Settings Sections
                    SettingsSection()
                }
                .padding()
            }
        }
        .navigationTitle("Account")
    }
}

struct ProfileCard: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.blue.gradient)
                    .frame(width: 80, height: 80)
                
                Text("SY")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 4) {
                Text("Sean Yan")
                    .font(.title2)
                    .bold()
                
                Text("Drive Account")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 12)
        )
    }
}

struct SettingsSection: View {
    var body: some View {
        VStack(spacing: 12) {
            SettingsRow(icon: "bell.fill", title: "Notifications", color: .red)
            SettingsRow(icon: "lock.fill", title: "Privacy", color: .blue)
            SettingsRow(icon: "square.and.arrow.up.fill", title: "Share Drive", color: .green)
            SettingsRow(icon: "questionmark.circle.fill", title: "Help & Support", color: .orange)
            SettingsRow(icon: "info.circle.fill", title: "About", color: .gray)
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .imageScale(.small)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 4)
        )
    }
}
#Preview {
    AccountView()
}

