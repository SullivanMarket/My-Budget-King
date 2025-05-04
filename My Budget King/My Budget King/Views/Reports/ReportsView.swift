//
//  ReportsView.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI
import AppKit

struct FullPageRTFExporter {
    static func generateRTF(from entries: [ActualEntry], selectedMonth: Int, selectedYear: Int) -> Data? {
        let attributed = NSMutableAttributedString()

        // Title + Subtitle
        let title = "Monthly Budget Report\n"
        let subtitle = String(format: "Month: %02d    Year: %04d\n\n", selectedMonth, selectedYear)
        attributed.append(NSAttributedString(string: title, attributes: [.font: NSFont.boldSystemFont(ofSize: 18)]))
        attributed.append(NSAttributedString(string: subtitle, attributes: [.font: NSFont.systemFont(ofSize: 14)]))

        // Use monospaced font for alignment
        let monoFont = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)

        // Income Section
        let incomeEntries = entries.filter { $0.categoryName == "Income" }
        if !incomeEntries.isEmpty {
            attributed.append(NSAttributedString(string: "Income\n", attributes: [.font: NSFont.boldSystemFont(ofSize: 16)]))
            for entry in incomeEntries {
                let name = entry.name.padding(toLength: 28, withPad: " ", startingAt: 0)
                let budgeted = String(format: "Budgeted: %.2f", entry.budgetedAmount).padding(toLength: 20, withPad: " ", startingAt: 0)
                let actual = String(format: "Actual: %.2f", entry.actualAmount).padding(toLength: 20, withPad: " ", startingAt: 0)
                let line = "\(name)\t\(budgeted)\t\(actual)\n"
                attributed.append(NSAttributedString(string: line, attributes: [.font: monoFont]))
            }
            attributed.append(NSAttributedString(string: "\n"))
        }

        // Expense Section
        let expenseEntries = entries.filter { $0.categoryName != "Income" }
        let grouped = Dictionary(grouping: expenseEntries, by: { $0.categoryName })
        let orderedCategories = [
            "Housing", "Transportation", "Insurance", "Food", "Children",
            "Legal", "Savings/Investments", "Loans", "Entertainment",
            "Taxes", "Personal Care", "Pets", "Gifts and Donations"
        ]

        attributed.append(NSAttributedString(string: "Expenses\n", attributes: [.font: NSFont.boldSystemFont(ofSize: 16)]))

        for category in orderedCategories {
            if let items = grouped[category] {
                attributed.append(NSAttributedString(string: "\(category)\n", attributes: [.font: NSFont.boldSystemFont(ofSize: 14)]))
                for entry in items {
                    let name = entry.name.padding(toLength: 28, withPad: " ", startingAt: 0)
                    let budgeted = String(format: "Budgeted: %.2f", entry.budgetedAmount).padding(toLength: 20, withPad: " ", startingAt: 0)
                    let actual = String(format: "Actual: %.2f", entry.actualAmount).padding(toLength: 20, withPad: " ", startingAt: 0)
                    let line = "\(name)\t\(budgeted)\t\(actual)\n"
                    attributed.append(NSAttributedString(string: line, attributes: [.font: monoFont]))
                }
                attributed.append(NSAttributedString(string: "\n"))
            }
        }

        // Final conversion
        let rtfData = try? attributed.data(from: NSRange(location: 0, length: attributed.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        return rtfData
    }
}



struct ReportsView: View {
    @State private var entries: [ActualEntry] = []
    @State private var selectedType: AppBudgetType = .personal
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme

    private var bodyTextColor: Color {
        colorScheme == .dark ? .white : .black
    }

    private let orderedExpenseCategories = [
        "Housing", "Transportation", "Insurance", "Food", "Children",
        "Legal", "Savings/Investments", "Loans", "Entertainment",
        "Taxes", "Personal Care", "Pets", "Gifts and Donations"
    ]

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    incomeSection
                    expenseSection
                }
                .padding()
                .foregroundColor(bodyTextColor)
            }
        }
        .background(settings.sectionBoxColor)
        .onAppear {
            print("📊 ReportsView is in \(colorScheme == .dark ? "Dark" : "Light") Mode")
            loadReportEntries()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Reports").font(.title).bold()
                Text("View budgeted vs actual income and expenses.")
                    .font(.subheadline)
            }

            Spacer()

            Picker("Month", selection: $selectedMonth) {
                ForEach(1...12, id: \.self) {
                    Text(Calendar.current.monthSymbols[$0 - 1]).tag($0)
                }
            }.frame(width: 120)

            Picker("", selection: $selectedType) {
                Text("Personal").tag(AppBudgetType.personal)
                Text("Family").tag(AppBudgetType.family)
            }.pickerStyle(.segmented).frame(width: 160)

            Button(action: {
                let selectedYear = Calendar.current.component(.year, from: Date())
                if let rtfData = FullPageRTFExporter.generateRTF(from: entries, selectedMonth: selectedMonth, selectedYear: selectedYear) {
                    let savePanel = NSSavePanel()
                    savePanel.allowedContentTypes = [.rtf]
                    savePanel.nameFieldStringValue = String(format: "%02d-%04d-report.rtf", selectedMonth, selectedYear)

                    if savePanel.runModal() == .OK, let url = savePanel.url {
                        do {
                            try rtfData.write(to: url)
                            print("✅ RTF saved to \(url.path)")
                        } catch {
                            print("❌ Failed to save RTF: \(error)")
                        }
                    }
                } else {
                    print("❌ Failed to generate RTF")
                }
            }) {
                Label("Export to RTF", systemImage: "doc.richtext")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(settings.headerColor)
    }

    private var incomeSection: some View {
        let incomeEntries = entries.filter { $0.categoryName == "Income" }
        return Group {
            if !incomeEntries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    // Label outside the background
                    Text("Income")
                        .font(.title2)
                        .bold()
                        .padding(.leading, 4)

                    // Only this section gets the colored background
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(incomeEntries) { entry in
                            reportRow(for: entry)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(settings.sectionBoxColor))
                }
            }
        }
    }

    private var expenseSection: some View {
        let expenses = entries.filter { $0.categoryName != "Income" }
        let grouped = Dictionary(grouping: expenses, by: { $0.categoryName })
        let sorted = orderedExpenseCategories.compactMap { grouped[$0] }

        let flat = sorted.flatMap { $0 }
        let mid = Int(ceil(Double(flat.count) / 2.0))
        let left = Array(flat.prefix(mid))  // ✅ Convert slice to Array
        let right = Array(flat.suffix(from: mid))  // ✅ Convert slice to Array

        return VStack(alignment: .leading, spacing: 16) {
            Text("Expenses")
                .font(.title2)
                .bold()
                .padding(.top, 12)
                .padding(.bottom, 4)
                .foregroundColor(bodyTextColor)

            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(left.groupedByCategory(ordered: orderedExpenseCategories), id: \.0) { (category, entries) in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.headline)
                                .padding(.leading, 4)

                            ForEach(entries) { entry in
                                reportRow(for: entry)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(settings.sectionBoxColor))
                    }
                }

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(right.groupedByCategory(ordered: orderedExpenseCategories), id: \.0) { (category, entries) in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category)
                                .font(.headline)
                                .padding(.leading, 4)

                            ForEach(entries) { entry in
                                reportRow(for: entry)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 12).fill(settings.sectionBoxColor))
                    }
                }
            }
        }
    }

    private func reportRow(for entry: ActualEntry) -> some View {
        HStack {
            Text(entry.name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(bodyTextColor)
            Text(String(format: "%.2f", entry.budgetedAmount))
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f", entry.actualAmount))
                .frame(width: 60, alignment: .trailing)
                .foregroundColor(.primary)
        }
        .padding(6)
        .background(RoundedRectangle(cornerRadius: 8).fill(settings.fieldRowColor))
    }

    private func loadReportEntries() {
        entries = BudgetDataManager.shared.loadActualEntries(
            for: selectedMonth,
            year: Calendar.current.component(.year, from: Date()),
            type: selectedType
        )
    }

private func exportRTF() {
    let entriesToExport = entries
    let selectedYear = String(Calendar.current.component(.year, from: Date()))
    let selectedMonthStr = String(format: "%02d", selectedMonth)
    let fileName = "\(selectedMonthStr)-\(selectedYear)-report.rtf"
    if let outputURL = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
        if let rtfData = FullPageRTFExporter.generateRTF(from: entriesToExport, selectedMonth: selectedMonth, selectedYear: Int(selectedYear) ?? 2025) {
            try? rtfData.write(to: outputURL)
            print("✅ RTF exported to \(outputURL.path)")
        } else {
            print("❌ Failed to generate RTF")
        }
    }
}
}

// MARK: - Grouping Extension for ActualEntry
private extension Array where Element == ActualEntry {
    func groupedByCategory(ordered: [String]) -> [(String, [ActualEntry])] {
        let grouped = Dictionary(grouping: self, by: { $0.categoryName })
        return ordered.compactMap { key in
            if let values = grouped[key] {
                return (key, values)
            }
            return nil
        }
    }
}
