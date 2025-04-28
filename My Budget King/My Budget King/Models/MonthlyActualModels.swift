//
//  MonthlyActualModels.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import Foundation

struct MonthlyActualEntry: Codable, Identifiable {
    var id = UUID()
    var categoryName: String
    var items: [MonthlyActualItem]
}

struct MonthlyActualItem: Codable, Identifiable {
    var id = UUID()
    var name: String
    var budgeted: Double
    var actual: Double
}
