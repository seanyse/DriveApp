//
//  MycarView.swift
//  Drive
//
//  Created by Sean Yan on 3/7/25.
//

import SwiftUI

struct AccountView: View {
    var body: some View {
        
        ScrollView {
            account()
            Spacer()
        }
        .padding()
        
    }
}
private func account() -> some View {
    ZStack {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(radius: 2.0)
            .frame(width: 350, height: 100)
            .padding(2)
        HStack {
            
            HStack {
                Circle()
                    .frame(width: 70)
            }
            HStack {
                VStack (alignment: .leading) {
                    Text("Sean Yan")
                        .font(.title)
                        .bold()
                    Text("Drive Account")
                }
                
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .imageScale(.medium)
        }.padding(35)
        
    }
}
#Preview {
    AccountView()
}
