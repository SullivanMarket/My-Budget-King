//
//  ActualEntry.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/26/25.
//

import Foundation

struct ActualEntry: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var budgetedAmount: Double
    var actualAmount: Double
}
