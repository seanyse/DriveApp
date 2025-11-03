//
//  MycarView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI

struct MycarView: View {
    var body: some View {
        
        ScrollView {
            carView()
            carView()
            carView()
            Spacer()
        }
        .padding()
        
    }
}
private func carView() -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2.0)
            .frame(width: 350, height: 115)
            .padding(2)
        HStack {
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(radius: 2.0)
                    .frame(width: 75, height: 75)
//                    .padding(3)


            }
            HStack {
                VStack(alignment: .leading) {
                    Text("Honda Pilot")
                        .font(.title2)
                        .bold()
                    Text("Year: 2020")
                    Text("HP: 276")

                }
                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .imageScale(.medium)

            }
           
        }.padding(.horizontal, 30)
    }
}

#Preview {
    MycarView()
}
