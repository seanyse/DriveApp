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
            baseStats()
            Text("Logged Drives")
                .font(.title2)
                .bold()
            
            driveCard()
            driveCard()
            
            
            Spacer()
        }
    }
}

private func baseStats() -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2.0)
            .frame(width: 350, height: 100)
            .padding(3)
        HStack {
            Spacer()
            VStack(alignment: .leading){
                Text("13")
                    .font(.title3)
                    .bold()
                Text("Hours Driven")
                
            }
            Spacer()
            VStack(alignment: .leading){
                Text("120")
                    .font(.title3)
                    .bold()
                Text("Top speed")
                
            }
            Spacer()
            VStack(alignment: .leading){
                Text("1256")
                    .font(.title3)
                    .bold()
                Text("Miles")
                
            }
            Spacer()
            
        }
        
    }
}

private func driveCard() -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2.0)
            .frame(width: 350, height: 75)
            .padding(3)
        HStack {
            Spacer()
            VStack(alignment: .leading){
                Text("Dec")
                Text("13")
                
            }
            Spacer()
            VStack(alignment: .leading){
                Text("Roswell Road")
                    .font(.title3)
                HStack {
                    Text("25 miles")
                    Text("30 mins")
                }
                
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .imageScale(.medium)
            Spacer()
        }
        
    }
}
#Preview {
    LogBookView()
}
