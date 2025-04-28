//
//  BudgetItem.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import Foundation

struct BudgetItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var amount: Double
}
