//
//  ContentView.swift
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
        NavigationStack {
            ZStack(alignment: .topLeading) {
                MapView(region: $locationManager.region)
                VStack {
                    Spacer()
                    menuView()
                    
                }

            }.ignoresSafeArea(.all)

        }
    }
}

private func menuView() -> some View {
    ZStack(alignment: .top) {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .opacity(0.85)
            .shadow(radius: 5.0)
            .frame(height: 450)

                    
        
        VStack(spacing:0) {
            Text("Good Afternoon")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                
            
            HStack {
                Spacer()
                actionButton_record()
                actionButton_record_drift()
                Spacer()
            }
            HStack {
                Spacer()
                actionButton_zerosixty()
                actionButton_top_speed()
                Spacer()
            }
//            Spacer()

        }
        Spacer()
        
    }
}

private func actionButton_record() -> some View {
    NavigationLink(destination: RecordDriveView()) { // Replace with your actual destination
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 2.0)
                    .frame(height: 135)
                    .padding(3)

                VStack {
                    Image(systemName: "car.rear")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.top)
                        .foregroundColor(.blue)

                    Text("Record Drive")
                        .font(.body)
                        .foregroundColor(.black)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                }
            }
            .contentShape(Rectangle()) // Ensures full tappability
        }

}

private func actionButton_record_drift() -> some View {
    NavigationLink(destination: RecordDriftView()) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 2.0)
                    .frame(height: 135)
                    .padding(3)

                VStack {
                    Image(systemName: "car.rear.and.tire.marks")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.top)
                        .foregroundColor(.blue)

                    Text("Record Drift")
                        .font(.body)
                        .foregroundColor(.black)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
                }
            }
        }
}

private func actionButton_zerosixty() -> some View {
    NavigationLink(destination: ZeroSixtyTestView()) {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .frame(height: 135)
                .padding(3)
            
            VStack {
                Image(systemName: "gearshift.layout.sixspeed")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .padding(.top)
                    .foregroundColor(.blue)
                
                Text("0-60 Test")
                    .font(.body)
                    .foregroundColor(.black)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(15)
            }
        }
    }
}

private func actionButton_top_speed() -> some View {
    NavigationLink(destination: TopSpeedTestView()) { 
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 2.0)
                    .frame(height: 135)
                    .padding(3)

                VStack {
                    Image(systemName: "gauge.with.dots.needle.100percent")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .padding(.top)
                        .foregroundColor(.blue)

                    Text("Top Speed Test")
                        .font(.body)
                        .foregroundColor(.black)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(15)
            }
        }
    }
}



struct MapView: View {
    @Binding var region: MKCoordinateRegion

    var body: some View {
        Map(
            coordinateRegion: $region,
            showsUserLocation: true,
            userTrackingMode: .none
        )
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    RecordView()
}
