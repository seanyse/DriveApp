//
//  ZeroSixtyAnalysisView.swift
//  Drive
//
//  Created by Sean Yan on 7/1/25.
//

import SwiftUI
import Charts

struct ZeroSixtyAnalysisView: View {
    let analysis_vel: [(timestamp: TimeInterval, speed: Double)]
    let final_time: Double
    let max_accel: Double
    var body: some View {
        Spacer()
        Text("Vehicle Performance Results - from DriveApp")
//            .font(.title)
//            .bold()
//        Spacer()
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .frame(width: 360, height: 290)
                .padding(3)
            VStack {
                zsChart(analysis_vel: analysis_vel)
                    .frame(width: 275, height: 250)
            }
        }
        resultViewSummary()
        resultView()
        Spacer()
        
        
    }
    private func resultViewSummary() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(radius: 2.0)
                .padding(3)
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "car.rear.road.lane.distance.2")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.top)
                        .foregroundColor(.blue)
                    
                    Text("1250ft")
                        .font(.title3)
                    Text("distance")
                        .font(.caption)
                        .foregroundColor(Color(.gray))

                    Spacer()
                    
                }

                Spacer()
                VStack {
                    Image(systemName: "gauge.with.dots.needle.67percent")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.top)
                        .foregroundColor(.blue)
                    //            Spacer()
                    
                    Text(String(format: "%.2fs", final_time))
                        .font(.title3)
                        .bold()
                    Text("0-60")
                        .foregroundColor(Color(.gray))
                        .font(.caption)
                    Spacer()
                    
                }
                Spacer()
                VStack {
                    Image(systemName: "cloud.bolt")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .padding(.top)
                        .foregroundColor(.blue)
                    
                    Text("2.1gs")
                        .font(.title3)
                    Text("max accel")
                        .font(.caption)
                        .foregroundColor(Color(.gray))

                    Spacer()
                    
                }
                Spacer()
            }
        }
        .frame(width: 360, height: 110)

    }

}

struct zsChart: View {
    let analysis_vel: [(timestamp: TimeInterval, speed: Double)]

    var body: some View {
        Chart {
            ForEach(analysis_vel.indices, id: \.self) { i in
                let point = analysis_vel[i]
                LineMark(
                    x: .value("Time", point.timestamp),
                    y: .value("Speed", point.speed)
                )
            }
        }
    }
}

private func resultView() -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2.0)
            .padding(3)
        HStack {
            Text("Complete View")
        }
    }.frame(width: 360, height: 210)
}

#Preview {
    // sample data
    let dummyData: [(timestamp: TimeInterval, speed: Double)] = [
            (timestamp: 0.0, speed: 0.0),
            (timestamp: 1.0, speed: 5.0),
            (timestamp: 2.0, speed: 15.0),
            (timestamp: 3.0, speed: 30.0),
            (timestamp: 4.0, speed: 60.0)
        ]
    ZeroSixtyAnalysisView(analysis_vel: dummyData, final_time: 4.53, max_accel: 1200.0)
}
