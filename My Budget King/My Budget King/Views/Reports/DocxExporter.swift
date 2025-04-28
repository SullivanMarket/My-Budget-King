//
//  DocxExporter.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/25/25.
//

import Foundation

class DocxExporter {
    static let shared = DocxExporter()
    
    private init() {}

    func createRTF(actuals: [ReportMonthlyActualEntry], selectedType: AppBudgetType, selectedYear: Int) -> Data? {
        var rtfString = "{\\rtf1\\ansi\\deff0"
        
        // Title
        rtfString += "\\qc\\b Budget Report for \(selectedType.rawValue.capitalized) - \(selectedYear)\\b0\\par\n"
        rtfString += "\\pard\\par\n"

        // Start Table
        rtfString += "\\trowd\\trgaph108\\trleft-108\n"
        rtfString += "\\cellx2000\\cellx4000\\cellx6000\\cellx8000\\cellx10000\n"
        rtfString += "\\intbl\\b Estimate\\cell\\cell Actual\\cell\\cell Trend\\cell\\row\n"
        rtfString += "\\b0\n"

        // Group entries: Income first, then Expenses by Category
        let incomeEntries = actuals.filter { $0.category.lowercased() == "income" }
        let expenseEntries = actuals.filter { $0.category.lowercased() != "income" }

        if !incomeEntries.isEmpty {
            rtfString += "\\pard\\b Income\\b0\\par\n"
            for entry in incomeEntries {
                rtfString += createTableRow(for: entry, isIncome: true)
            }
        }

        let orderedCategories = [
            "Housing", "Transportation", "Insurance", "Food", "Children", "Legal",
            "Savings/Investments", "Loans", "Entertainment", "Taxes", "Personal Care",
            "Pets", "Gifts and Donations"
        ]

        for category in orderedCategories {
            let entries = expenseEntries.filter { $0.category == category }
            if !entries.isEmpty {
                rtfString += "\\pard\\b \(category)\\b0\\par\n"
                for entry in entries {
                    rtfString += createTableRow(for: entry, isIncome: false)
                }
            }
        }

        // End Document
        rtfString += "}"

        if let data = rtfString.data(using: .utf8) {
            return data
        }
        return nil
    }

    private func createTableRow(for entry: ReportMonthlyActualEntry, isIncome: Bool) -> String {
        let formattedEstimate = String(format: "$%.2f", entry.budgetedAmount)
        let formattedActual = String(format: "$%.2f", entry.actualAmount)
        let trendSymbol = trendSymbolFor(entry: entry, isIncome: isIncome)

        return "\\trowd\\trgaph108\\trleft-108\n" +
               "\\cellx2000\\cellx4000\\cellx6000\\cellx8000\\cellx10000\n" +
               "\\intbl \(formattedEstimate)\\cell\\cell \(formattedActual)\\cell\\cell \(trendSymbol)\\cell\\row\n"
    }

    private func trendSymbolFor(entry: ReportMonthlyActualEntry, isIncome: Bool) -> String {
        if entry.actualAmount == entry.budgetedAmount {
            return "="
        } else if isIncome {
            return entry.actualAmount > entry.budgetedAmount ? "↑" : "↓" // up / down arrows
        } else {
            return entry.actualAmount > entry.budgetedAmount ? "↓" : "↑"
        }
    }
    
    // MARK: - Create Formatted RTF
    func createFormattedRtf(
        actuals: [ReportMonthlyActualEntry],
        groupedExpenses: [String: [ReportMonthlyActualEntry]],
        selectedType: AppBudgetType,
        selectedYear: Int
    ) -> String {
        var rtf = ""

        rtf += "\\b My Budget King Report \\b0\\line"
        rtf += "Budget Type: \(selectedType.rawValue.capitalized)\\line"
        rtf += "Year: \(selectedYear)\\line\\line"

        rtf += "\\b Income \\b0\\line"
        for entry in actuals.filter({ $0.category.lowercased() == "income" }) {
            rtf += "\(entry.name)\\tab Est: $\(String(format: "%.2f", entry.budgetedAmount))\\tab Act: $\(String(format: "%.2f", entry.actualAmount))\\line"
        }

        rtf += "\\line\\b Expenses \\b0\\line"
        for category in groupedExpenses.keys.sorted() {
            if let entries = groupedExpenses[category] {
                rtf += "\\line\\b \(category) \\b0\\line"
                for entry in entries {
                    rtf += "\(entry.name)\\tab Est: $\(String(format: "%.2f", entry.budgetedAmount))\\tab Act: $\(String(format: "%.2f", entry.actualAmount))\\line"
                }
            }
        }

        return "{\\rtf1\\ansi\n\(rtf)\n}"
    }
}
