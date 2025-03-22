//
//  ContentView.swift
//  Drive
//
//  Created by Sean Yan on 3/9/25.
//
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RecordView()
                .tabItem {
                    Label("Record", systemImage: "record.circle")
                }
            TrackView()
                .tabItem {
                    Label("Tracks", systemImage: "point.forward.to.point.capsulepath")
                }
            LogBookView()
                .tabItem {
                    Label("Logbook", systemImage: "book")
                }
            MycarView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle")
                }
        }
    }
}


#Preview {
    ContentView()
}
