//
//  BudgetDataManager.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import Foundation

class BudgetDataManager {
    static let shared = BudgetDataManager()

    private init() {}

    // MARK: - Load Categories for Budget Setup
    func loadCategories(for type: AppBudgetType) -> [BudgetCategory] {
        let filename = "\(type.rawValue.lowercased())_categories.json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([BudgetCategory].self, from: data)
            print("✅ Loaded \(decoded.count) categories for \(type)")
            return decoded
        } catch {
            print("❌ Failed to load categories: \(error)")
            return []
        }
    }

    // MARK: - Load/Save Monthly Budgets for Budget Setup
    func loadMonthlyBudgets(for year: Int, type: AppBudgetType) -> [BudgetCategory] {
        let filename = "\(type.rawValue.lowercased())_budget_\(year).json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([BudgetCategory].self, from: data)
            print("✅ Loaded \(decoded.count) monthly budgets for \(type) - \(year)")
            return decoded
        } catch {
            print("❌ Failed to load monthly budgets: \(error)")
            return []
        }
    }

    func saveMonthlyBudgets(_ categories: [BudgetCategory], for year: Int, type: AppBudgetType) {
        let filename = "\(type.rawValue.lowercased())_budget_\(year).json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try JSONEncoder().encode(categories)
            try data.write(to: url)
            print("✅ Saved monthly budgets for \(type) - \(year)")
        } catch {
            print("❌ Failed to save monthly budgets: \(error)")
        }
    }

    // MARK: - Load/Save Monthly Actuals for Monthly Actuals Page
    // MARK: - Load Monthly Actuals (for MonthlyActualsView and Reports)
    func loadMonthlyActuals(for year: Int, type: AppBudgetType) -> [MonthlyActualEntry] {
        let filename = "budget_\(type.rawValue.lowercased())_actuals_\(year).json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        if FileManager.default.fileExists(atPath: url.path) {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([MonthlyActualEntry].self, from: data)
                print("✅ Loaded \(decoded.count) monthly actual entries for \(type) - \(year)")
                return decoded
            } catch {
                print("❌ Failed to load monthly actual entries: \(error)")
                return []
            }
        } else {
            print("⚡ No budget actuals found for \(type) \(year).")
            return []
        }
    }

    func saveMonthlyActuals(_ entries: [MonthlyActualEntry], for year: Int, type: AppBudgetType) {
        let filename = "\(type.rawValue.lowercased())_actuals_\(year).json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: url)
            print("✅ Saved monthly actuals for \(type) - \(year)")
        } catch {
            print("❌ Failed to save monthly actuals: \(error)")
        }
    }

    // MARK: - Load Flat Actuals for Reports
    // MARK: - Load Flat Actuals for Reports
    func loadActualsForReports(for year: Int, type: AppBudgetType) -> [ActualEntry] {
        let filename = "budget_\(type.rawValue.lowercased())_actuals_\(year).json"
        let url = getDocumentsDirectory().appendingPathComponent(filename)

        do {
            let data = try Data(contentsOf: url)
            let decodedMonthly = try JSONDecoder().decode([MonthlyActualEntry].self, from: data)

            // Flatten MonthlyActualEntry → ActualEntry
            let actuals: [ActualEntry] = decodedMonthly.flatMap { monthly in
                monthly.items.map { item in
                    ActualEntry(
                        id: item.id,
                        name: item.name,
                        category: monthly.categoryName,
                        budgetedAmount: item.budgeted,
                        actualAmount: item.actual
                    )
                }
            }

            print("📊 Loaded \(actuals.count) actuals for reports from \(filename)")
            return actuals
        } catch {
            print("❌ Failed to load report actuals: \(error)")
            return []
        }
    }

    // MARK: - Grouped Actuals for Reports Page
    func loadGroupedActualsForReports(for year: Int, type: AppBudgetType) -> ([ReportMonthlyActualEntry], [String: [ReportMonthlyActualEntry]]) {
        let flat = loadActualsForReports(for: year, type: type)

        // Convert ActualEntry -> ReportMonthlyActualEntry
        let converted = flat.map { actual in
            ReportMonthlyActualEntry(
                name: actual.name,
                category: actual.category,
                budgetedAmount: actual.budgetedAmount,
                actualAmount: actual.actualAmount
            )
        }

        let grouped = Dictionary(grouping: converted.filter { $0.category.lowercased() != "income" }) { $0.category }
        return (converted, grouped)
    }

    // MARK: - Load Default Categories from JSON in Bundle
    func loadDefaultCategories(for type: AppBudgetType) -> [BudgetCategory] {
        let filename = type == .personal ? "default_personal_categories" : "default_family_categories"

        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Failed to locate \(filename).json in bundle")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([BudgetCategory].self, from: data)
            print("✅ Loaded \(decoded.count) default categories for \(type)")
            return decoded
        } catch {
            print("❌ Failed to decode default categories: \(error)")
            return []
        }
    }

    // MARK: - Helper
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
