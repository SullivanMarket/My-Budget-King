//
//  Models.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/25/25.
//

import Foundation

import Foundation

struct ReportMonthlyActualEntry: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var budgetedAmount: Double
    var actualAmount: Double
}

enum ReportBudgetType: String, CaseIterable {
    case personal
    case family
}
