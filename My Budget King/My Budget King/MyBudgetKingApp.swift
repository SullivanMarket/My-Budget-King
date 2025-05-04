//
//  MyBudgetKingApp.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import SwiftUI

@main
struct MyBudgetKingApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    MainAppView()
                        .transition(.opacity)
                        .frame(minWidth: 1200, minHeight: 700) // Adjust these values as needed
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showSplash = false
                    }
                }
            }
        }
        .windowResizability(.contentSize) // Prevent shrinking smaller than content
    }
}
