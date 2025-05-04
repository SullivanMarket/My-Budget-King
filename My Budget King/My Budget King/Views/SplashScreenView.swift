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
    @ObservedObject private var appState = AppState.shared // 🆕 Watch app readiness

    var body: some View {
        ZStack {
            // Background Splash screen
            VStack(spacing: 20) {
                Text("My Budget King")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Image("mbk-icon-1024")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)

                Text("Version 1.1.0")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(settings.headerColor)
            .ignoresSafeArea()

            // Main App View fades in
            if isActive {
                MainAppView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onReceive(appState.$isAppReady) { ready in
            if ready {
                withAnimation(.easeInOut(duration: 0.5)) {
                    isActive = true
                }
            }
        }
    }
}
