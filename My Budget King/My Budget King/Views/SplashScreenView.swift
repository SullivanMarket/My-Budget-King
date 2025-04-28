//
//  SplashScreenView.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        ZStack {
            settings.headerColor
                .ignoresSafeArea()

            if isActive {
                MainAppView()
            } else {
                VStack(spacing: 20) {
                    Text("My Budget King")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    Image("mbk-icon-1024")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)

                    Text("Version 1.0.0")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .transition(.opacity) // fade nicely
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isActive = true
                        }
                    }
                }
            }
        }
    }
}
