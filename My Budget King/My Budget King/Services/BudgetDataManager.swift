//
//  BudgetDataManager.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

//
//  BudgetDataManager.swift
//  My Budget King
//

import Foundation

struct MonthlyActualFlatEntry: Identifiable, Codable {
    var id: UUID
    var name: String
    var categoryName: String
    var budgetedAmount: Double
    var actualAmount: Double
}

class BudgetDataManager {
    static let shared = BudgetDataManager()

    private init() {}

    // Save actuals to file
    func saveMonthlyActuals(_ entries: [MonthlyActualFlatEntry], for month: Int, year: Int, type: AppBudgetType) {
        let filename = String(format: "%02d-%04d-actuals.json", month, year)
        guard let url = fileURL(for: filename) else { return }

        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: url)
            print("✅ Saved actual entries to \(filename)")
        } catch {
            print("❌ Failed to save actual entries: \(error)")
        }
    }

    // Load actuals from file
    func loadActualEntries(for month: Int, year: Int, type: AppBudgetType) -> [ActualEntry] {
        let filename = String(format: "%02d-%04d-actuals.json", month, year)
        guard let url = fileURL(for: filename),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load actual entries from \(filename)")
            return []
        }

        do {
            let flat = try JSONDecoder().decode([MonthlyActualFlatEntry].self, from: data)
            let mapped = flat.map {
                ActualEntry(id: $0.id, name: $0.name, categoryName: $0.categoryName, budgetedAmount: $0.budgetedAmount, actualAmount: $0.actualAmount)
            }
            return mapped
        } catch {
            print("❌ Decoding error: \(error)")
            return []
        }
    }

    // Helper to get file URL
    private func fileURL(for filename: String) -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename)
    }
    
    // MARK: - Legacy Support for Budget Setup

    func loadDefaultCategories(for type: AppBudgetType) -> [BudgetCategory] {
        let filename = type == .personal ? "default_personal_categories.json" : "default_family_categories.json"
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil),
              let data = try? Data(contentsOf: url),
              let categories = try? JSONDecoder().decode([BudgetCategory].self, from: data) else {
            print("❌ Failed to load default categories for \(type)")
            return []
        }
        return categories
    }

    func loadMonthlyBudgets(for year: Int, type: AppBudgetType) -> [BudgetCategory] {
        let filename = "\(year)-\(type.rawValue)-budget.json"
        let url = documentsDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url),
              let categories = try? JSONDecoder().decode([BudgetCategory].self, from: data) else {
            print("❌ Failed to load monthly budgets from \(filename)")
            return []
        }
        return categories
    }

    func saveMonthlyBudgets(_ categories: [BudgetCategory], for year: Int, type: AppBudgetType) {
        let filename = "\(year)-\(type.rawValue)-budget.json"
        let url = documentsDirectory.appendingPathComponent(filename)
        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: url)
            print("✅ Saved monthly budgets to \(filename)")
        } catch {
            print("❌ Failed to save monthly budgets: \(error)")
        }
    }
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}
