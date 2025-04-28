//
//  MyBudgetKingApp.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import SwiftUI

@main
struct MyBudgetKingApp: App {
    @State private var showingSplash = true
    @State private var fadeOut = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainAppView()
                    .opacity(showingSplash ? 0 : 1)

                if showingSplash {
                    SplashScreenView()
                        .opacity(fadeOut ? 0 : 1)
                        .onAppear {
                            // Start timer
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    fadeOut = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showingSplash = false
                                }
                            }
                        }
                }
            }
        }
    }
}
