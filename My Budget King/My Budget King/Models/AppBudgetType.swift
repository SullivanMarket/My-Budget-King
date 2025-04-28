//
//  AppBudgetType.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import Foundation

enum AppBudgetType: String, CaseIterable, Identifiable {
    case personal
    case family

    var id: String { rawValue }
}
