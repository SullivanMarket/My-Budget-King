//
//  MonthlyComparisonExporter.swift
//  My Budget King
//
//  Created by ChatGPT on 5/3/25.
//

import AppKit

struct MonthlyComparisonExporter {
    static func generateRTF(from entries: [MonthlyComparisonEntryV4], selectedMonth: Int, selectedYear: Int) -> Data? {
        let attributed = NSMutableAttributedString()

        let title = "Monthly Comparison Report\n"
        let subtitle = String(format: "Month: %02d    Year: %04d\n\n", selectedMonth, selectedYear)
        attributed.append(NSAttributedString(string: title, attributes: [.font: NSFont.boldSystemFont(ofSize: 18)]))
        attributed.append(NSAttributedString(string: subtitle, attributes: [.font: NSFont.systemFont(ofSize: 14)]))

        let monoFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)

        let monthA = selectedMonth > 1 ? DateFormatter().monthSymbols[selectedMonth - 2] : "Previous"
        let monthB = DateFormatter().monthSymbols[selectedMonth - 1]

        // Column header
        let nameCol = "Name".padding(toLength: 28, withPad: " ", startingAt: 0)
        let monthACol = "\(monthA) \(selectedYear)".padding(toLength: 16, withPad: " ", startingAt: 0)
        let monthBCol = "\(monthB) \(selectedYear)".padding(toLength: 16, withPad: " ", startingAt: 0)
        let trendCol = "Trend".padding(toLength: 6, withPad: " ", startingAt: 0)
        let header = "\(nameCol)\(monthACol)\(monthBCol)\(trendCol)\n"
        attributed.append(NSAttributedString(string: header, attributes: [.font: monoFont]))

        // Income
        let incomeEntries = entries.filter { $0.category == "Income" }
        if !incomeEntries.isEmpty {
            attributed.append(NSAttributedString(string: "\nIncome\n", attributes: [.font: NSFont.boldSystemFont(ofSize: 16)]))
            for entry in incomeEntries {
                let name = entry.name.padding(toLength: 28, withPad: " ", startingAt: 0)
                let previous = String(format: "%.2f", entry.previousActual).padding(toLength: 16, withPad: " ", startingAt: 0)
                let current = String(format: "%.2f", entry.currentActual).padding(toLength: 16, withPad: " ", startingAt: 0)
                let trend = entry.trendArrow.padding(toLength: 6, withPad: " ", startingAt: 0)
                let line = "\(name)\(previous)\(current)\(trend)\n"
                attributed.append(NSAttributedString(string: line, attributes: [.font: monoFont]))
            }
        }

        // Expenses
        let expenseEntries = entries.filter { $0.category != "Income" }
        let grouped = Dictionary(grouping: expenseEntries, by: { $0.category })
        let orderedCategories = [
            "Housing", "Transportation", "Insurance", "Food", "Children",
            "Legal", "Savings/Investments", "Loans", "Entertainment",
            "Taxes", "Personal Care", "Pets", "Gifts and Donations"
        ]

        attributed.append(NSAttributedString(string: "\nExpenses\n", attributes: [.font: NSFont.boldSystemFont(ofSize: 16)]))

        for category in orderedCategories {
            if let items = grouped[category] {
                attributed.append(NSAttributedString(string: "\(category)\n", attributes: [.font: NSFont.boldSystemFont(ofSize: 14)]))
                let nameCol = "Name".padding(toLength: 28, withPad: " ", startingAt: 0)
                let monthACol = "\(monthA) \(selectedYear)".padding(toLength: 16, withPad: " ", startingAt: 0)
                let monthBCol = "\(monthB) \(selectedYear)".padding(toLength: 16, withPad: " ", startingAt: 0)
                let trendCol = "Trend".padding(toLength: 6, withPad: " ", startingAt: 0)
                let categoryHeader = "\(nameCol)\(monthACol)\(monthBCol)\(trendCol)\n"
                attributed.append(NSAttributedString(string: categoryHeader, attributes: [.font: monoFont]))
                for entry in items {
                    let name = entry.name.padding(toLength: 28, withPad: " ", startingAt: 0)
                    let previous = String(format: "%.2f", entry.previousActual).padding(toLength: 16, withPad: " ", startingAt: 0)
                    let current = String(format: "%.2f", entry.currentActual).padding(toLength: 16, withPad: " ", startingAt: 0)
                    let trend = entry.trendArrow.padding(toLength: 6, withPad: " ", startingAt: 0)
                    let line = "\(name)\(previous)\(current)\(trend)\n"
                    attributed.append(NSAttributedString(string: line, attributes: [.font: monoFont]))
                }
                attributed.append(NSAttributedString(string: "\n"))
            }
        }

        return try? attributed.data(from: NSRange(location: 0, length: attributed.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
    }
}

extension MonthlyComparisonEntryV4 {
    var trendArrow: String {
        if currentActual > previousActual {
            return "↑"
        } else if currentActual < previousActual {
            return "↓"
        } else {
            return "="
        }
    }
}
