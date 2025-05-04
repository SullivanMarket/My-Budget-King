//
//  AppState.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/28/25.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isAppReady: Bool = false

    private init() {}
}
