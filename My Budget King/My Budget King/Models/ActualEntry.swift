//
//  ActualEntry.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/26/25.
//

import Foundation

struct ActualEntry: Identifiable, Codable {
    var id: UUID
    var name: String
    var categoryName: String  // ✅ Add this
    var budgetedAmount: Double
    var actualAmount: Double
}
