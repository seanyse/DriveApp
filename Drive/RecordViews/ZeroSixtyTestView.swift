//
//  ZeroSixtyTestView.swift
//  Drive
//
//  Created by Sean Yan on 3/9/25.
//

import SwiftUI

struct ZeroSixtyTestView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var fusion = ZeroSixtyManager()
    @State private var acceleration: Double = 0.000


    var body: some View {
        VStack {
            
            Spacer()
            guiView()
            Spacer()
            zeroSixtyView()
            HStack {
                speedView()
                accelerationView()
            }
            statusView()
            Spacer()

        }
    }
    private func guiView() -> some View {
            // compute once per body-eval
            // clamps progess to be a valid value for the gui, progress is value 0-1
            let progress = min(max(fusion.speed / 60, 0), 1)

            return ZStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 15)
                    .frame(width: 300, height: 300)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, lineWidth: 15)
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(90))
                    .animation(.linear(duration: 0.5), value: progress)
        }
    }
    
    private func speedView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .frame(width: 170, height: 100)
                .padding(3)
            VStack {
                Text(String(format: "%.1f mph", fusion.speed))
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
                Text("\(fusion.a_mag, specifier: "%.2f") g")
            }
        }
    }

    private func statusView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .frame(width: 350, height: 50)
                .padding(3)
            VStack {
                Button(action: {
                    fusion.userStart.toggle()
                    
                    fusion.userStart ? fusion.startRecording() : fusion.stopRecording()
                }) {
                    Text(fusion.userStart ? "Abort Recording": "Start Recording")
                }
            }
        }
    }
    private func zeroSixtyView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .frame(width: 350, height: 100)
                .padding(3)
            VStack {
                Text("0-60:")
            }
        }
    }


}




#Preview {
    ZeroSixtyTestView()
}
