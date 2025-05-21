//
//  MonthlyComparisonPage.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/30/25.
//

import SwiftUI
import UniformTypeIdentifiers
import Foundation

struct MonthlyComparisonEntryV4: Identifiable {
    var id: UUID
    var name: String
    var category: String
    var budgeted: Double
    var previousActual: Double
    var currentActual: Double

    init(id: UUID, name: String, category: String, budgeted: Double, previousActual: Double, currentActual: Double) {
        self.id = id
        self.name = name
        self.category = category
        self.budgeted = budgeted
        self.previousActual = previousActual
        self.currentActual = currentActual
    }
}

struct MonthlyComparisonPage: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var previousMonth = 1
    @State private var previousYear = 2025
    @State private var currentMonth = 2
    @State private var currentYear = 2025
    @State private var results: [MonthlyComparisonEntryV4] = []
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var comparisonEntries: [MonthlyComparisonEntryV4] = []
    @State private var showEmptyExportAlert = false
    // Computed property for filtered and deduplicated income entries
    private var incomeEntries: [MonthlyComparisonEntryV4] {
        // Reset and deduplicate using a Set<UUID>
        var seen = Set<UUID>()
        return results.filter { $0.category == "Income" }
            .filter { entry in
                guard !seen.contains(entry.id) else { return false }
                seen.insert(entry.id)
                return true
            }
    }

    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    let years = Array(2020...2025)

    // Computed property for filtered and deduplicated expense entries
    private var expenseEntries: [MonthlyComparisonEntryV4] {
        // Reset and deduplicate using a Set<UUID>
        var seen = Set<UUID>()
        return results.filter { $0.category != "Income" }
            .filter { entry in
                guard !seen.contains(entry.id) else { return false }
                seen.insert(entry.id)
                return true
            }
    }

    // Computed property for grouped expense categories
    private var expenseCategories: [String: [MonthlyComparisonEntryV4]] {
        Dictionary(grouping: expenseEntries, by: { $0.category })
    }

    // Computed property for sorted expense category names
    private var sortedExpenseCategories: [String] {
        expenseCategories.keys.sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Comparison")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                    Text("Compare actual values between two selected months")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }

                Spacer()

                HStack(alignment: .top, spacing: 24) {
                    // Dropdown Columns
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Month A").font(.subheadline).bold()
                        Picker("Month A", selection: $previousMonth) {
                            ForEach(1...12, id: \.self) {
                                Text(DateFormatter().monthSymbols[$0 - 1]).tag($0)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 140)

                        Picker("Year A", selection: $previousYear) {
                            ForEach(2020...2030, id: \.self) {
                                Text(String($0)).tag($0)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 100)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Month B").font(.subheadline).bold()
                        Picker("Month B", selection: $currentMonth) {
                            ForEach(1...12, id: \.self) {
                                Text(DateFormatter().monthSymbols[$0 - 1]).tag($0)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 140)

                        Picker("Year B", selection: $currentYear) {
                            ForEach(2020...2030, id: \.self) {
                                Text(String($0)).tag($0)
                            }
                        }
                        .labelsHidden()
                        .frame(width: 100)
                    }

                    // Buttons
                    VStack(alignment: .trailing, spacing: 12) {
                        Button(action: {
                            results = loadComparison(previousMonth: previousMonth, previousYear: previousYear, currentMonth: currentMonth, currentYear: currentYear)
                        }) {
                            Label("Load", systemImage: "arrow.clockwise")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)

                        Button(action: {
                            if results.isEmpty {
                                showEmptyExportAlert = true
                                return
                            }

                            let savePanel = NSSavePanel()
                            savePanel.allowedContentTypes = [.rtf]
                            savePanel.nameFieldStringValue = String(format: "%02d-%04d-comparison.rtf", currentMonth, currentYear)
                            savePanel.title = "Save Monthly Comparison Report"

                            if savePanel.runModal() == .OK, let outputURL = savePanel.url {
                                if let rtfData = MonthlyComparisonExporter.generateRTF(
                                    from: results,
                                    selectedMonth: currentMonth,
                                    selectedYear: currentYear
                                ) {
                                    do {
                                        try rtfData.write(to: outputURL)
                                        print("✅ RTF saved to \(outputURL.path)")
                                    } catch {
                                        print("❌ Failed to save RTF: \(error.localizedDescription)")
                                    }
                                } else {
                                    print("❌ Failed to generate RTF data.")
                                }
                            }
                        }) {
                            Label("Export RTF", systemImage: "doc.plaintext")
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(colorScheme == .dark ? Color.black : Color.white)
                                .cornerRadius(10)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .alert(isPresented: $showEmptyExportAlert) {
                            Alert(
                                title: Text("Nothing to Export"),
                                message: Text("Please load comparison data before exporting."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                    }
                }
            }
            .padding()
            .background(AppSettings.shared.headerColor)

            if results.isEmpty {
                Spacer()
                Text("No data to display. Please load a comparison.")
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // INCOME SECTION
                        if !incomeEntries.isEmpty {
                            IncomeSectionView(entries: incomeEntries, trendSymbol: trendSymbol)
                        }

                        // EXPENSES SECTION
                        if !expenseEntries.isEmpty {
                            ExpenseCategoryGridView(
                                expenseCategories: expenseCategories,
                                sortedCategories: sortedExpenseCategories,
                                trendSymbol: trendSymbol
                            )
                        }
// MARK: - Extracted Views

                    }
                    .padding(.vertical)
                }
                .background(AppSettings.shared.sectionBoxColor)
            }
        }
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            print("🌓 Monthly Comparison Page is in \(colorScheme == .dark ? "Dark" : "Light") Mode")
        }
    }

    private func trendSymbol(previous: Double, current: Double) -> String {
        if current > previous {
            return "↑"
        } else if current < previous {
            return "↓"
        } else {
            return "="
        }
    }

    private func loadComparison(previousMonth: Int, previousYear: Int, currentMonth: Int, currentYear: Int) -> [MonthlyComparisonEntryV4] {
        let previousKey = String(format: "%02d-%04d", previousMonth, previousYear)
        let currentKey = String(format: "%02d-%04d", currentMonth, currentYear)

        let previousFileName = "\(previousKey)-actuals.json"
        let currentFileName = "\(currentKey)-actuals.json"

        guard let previousURL = findJSONFile(named: previousFileName) ?? promptForFile(named: previousFileName),
              let currentURL = findJSONFile(named: currentFileName) ?? promptForFile(named: currentFileName) else {
            print("❌ One or both actuals files not found.")
            return []
        }

        do {
            let previousData = try Data(contentsOf: previousURL)
            let currentData = try Data(contentsOf: currentURL)

            let decoder = JSONDecoder()

            let previousCategories: [ExpenseCategoryV4]
            let currentCategories: [ExpenseCategoryV4]

            do {
                previousCategories = try decoder.decode([ExpenseCategoryV4].self, from: previousData)
            } catch {
                print("⚠️ Fallback: Decoding previous file as flat entries")
                let flat = try decoder.decode([MonthlyActualEntryV2].self, from: previousData)
                previousCategories = groupFlatEntries(flat)
            }

            do {
                currentCategories = try decoder.decode([ExpenseCategoryV4].self, from: currentData)
            } catch {
                print("⚠️ Fallback: Decoding current file as flat entries")
                let flat = try decoder.decode([MonthlyActualEntryV2].self, from: currentData)
                currentCategories = groupFlatEntries(flat)
            }

            print("✅ Loaded previous categories: \(previousCategories.count)")
            print("✅ Loaded current categories: \(currentCategories.count)")

            let previousActuals = MonthlyActualEntryV4(
                month: previousMonth,
                year: previousYear,
                type: "actuals",
                incomes: extractIncome(from: previousCategories),
                expenseCategories: extractExpenses(from: previousCategories)
            )
            let currentActuals = MonthlyActualEntryV4(
                month: currentMonth,
                year: currentYear,
                type: "actuals",
                incomes: extractIncome(from: currentCategories),
                expenseCategories: extractExpenses(from: currentCategories)
            )

            let mergedEntries = ComparisonHelperV4.flatten(previousActuals: previousActuals, currentActuals: currentActuals)

            print("✅ Merged entries: \(mergedEntries.count)")
            return mergedEntries
        } catch {
            print("❌ Failed to decode one or both files: \(error)")
            return []
        }
    }
    
    private func groupFlatEntries(_ flat: [MonthlyActualEntryV2]) -> [ExpenseCategoryV4] {
        let grouped = Dictionary(grouping: flat) { $0.categoryName }
        return grouped.map { key, items in
            ExpenseCategoryV4(
                categoryName: key,
                items: items.map {
                    ComparisonEntryV4(
                        id: $0.id,
                        name: $0.name,
                        budgeted: $0.budgetedAmount,
                        actual: $0.actualAmount
                    )
                }
            )
        }
    }

    // Helper to extract income entries from decoded ExpenseCategoryV4 array
    private func extractIncome(from categories: [ExpenseCategoryV4]) -> [ComparisonEntryV4] {
        // Assume income categories are those with categoryName == "Income"
        // This logic may need to be adjusted depending on your data structure
        for cat in categories {
            if cat.categoryName == "Income" {
                return cat.items
            }
        }
        return []
    }

    // Helper to extract expense categories from decoded ExpenseCategoryV4 array
    private func extractExpenses(from categories: [ExpenseCategoryV4]) -> [ExpenseCategoryV4] {
        // Filter out the income category
        return categories.filter { $0.categoryName != "Income" }
    }

    private func promptForFile(named name: String) -> URL? {
        let panel = NSOpenPanel()
        panel.title = "Select \(name)"
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.json]
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            return panel.url
        }
        return nil
    }

    private func findJSONFile(named name: String) -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let candidate = documentsURL?.appendingPathComponent(name)
        if let url = candidate, FileManager.default.fileExists(atPath: url.path) {
            return url
        }
        return nil
    }
}

// MARK: - Data Models & Helpers

struct MonthlyActualEntryV4: Codable {
    var month: Int
    var year: Int
    var type: String
    var incomes: [ComparisonEntryV4]
    var expenseCategories: [ExpenseCategoryV4]
}

struct ComparisonEntryV4: Codable, Identifiable {
    var id: UUID
    var name: String
    var budgeted: Double
    var actual: Double
}

struct ExpenseCategoryV4: Codable {
    var categoryName: String
    var items: [ComparisonEntryV4]
}

struct ComparisonHelperV4 {
    static func flatten(previousActuals: MonthlyActualEntryV4, currentActuals: MonthlyActualEntryV4) -> [MonthlyComparisonEntryV4] {
        var previousDict: [UUID: ComparisonEntryV4] = [:]
        var currentDict: [UUID: ComparisonEntryV4] = [:]

        for income in previousActuals.incomes {
            previousDict[income.id] = income
        }
        for category in previousActuals.expenseCategories {
            for item in category.items {
                previousDict[item.id] = item
            }
        }

        for income in currentActuals.incomes {
            currentDict[income.id] = income
        }
        for category in currentActuals.expenseCategories {
            for item in category.items {
                currentDict[item.id] = item
            }
        }

        // Collect all unique IDs
        let allIDs = Set(previousDict.keys).union(currentDict.keys)

        var mergedEntries: [MonthlyComparisonEntryV4] = []

        for id in allIDs {
            let prevEntry = previousDict[id]
            let currEntry = currentDict[id]

            // Use name and category from current if available, else previous
            let name = currEntry?.name ?? prevEntry?.name ?? "Unknown"
            let category = findCategory(for: id, in: currentActuals) ?? findCategory(for: id, in: previousActuals) ?? "Unknown"
            let budgeted = prevEntry?.budgeted ?? currEntry?.budgeted ?? 0.0
            let previousActual = prevEntry?.actual ?? 0.0
            let currentActual = currEntry?.actual ?? 0.0

            mergedEntries.append(MonthlyComparisonEntryV4(
                id: id,
                name: name,
                category: category,
                budgeted: budgeted,
                previousActual: previousActual,
                currentActual: currentActual
            ))
        }

        // Sort alphabetically by name
        mergedEntries.sort { $0.name < $1.name }

        return mergedEntries
    }

    private static func findCategory(for id: UUID, in actuals: MonthlyActualEntryV4) -> String? {
        for income in actuals.incomes {
            if income.id == id {
                return "Income"
            }
        }
        for category in actuals.expenseCategories {
            for item in category.items {
                if item.id == id {
                    return category.categoryName
                }
            }
        }
        return nil
    }
}

struct IncomeSectionView: View {
    let entries: [MonthlyComparisonEntryV4]
    let trendSymbol: (Double, Double) -> String

    var body: some View {
        // Move the Income label outside the VStack, with horizontal and top padding
        VStack(alignment: .leading, spacing: 0) {
            Text("Income")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 6)
            VStack(alignment: .leading, spacing: 12) {
                // Table header
                HStack {
                    Text("Name")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Budgeted")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 80, alignment: .trailing)
                    Text("Previous Actual")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 110, alignment: .trailing)
                    Text("Current Actual")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 100, alignment: .trailing)
                    Text("Trend")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .frame(width: 40, alignment: .center)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(AppSettings.shared.sectionBoxColor.opacity(0.7))
                .cornerRadius(8)
                ForEach(entries) { entry in
                    HStack {
                        Text(entry.name)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(String(format: "%.2f", entry.budgeted))
                            .foregroundColor(.primary)
                            .frame(width: 80, alignment: .trailing)
                        Spacer()
                        Text(String(format: "%.2f", entry.previousActual))
                            .foregroundColor(.primary)
                            .frame(width: 110, alignment: .trailing)
                        Text(String(format: "%.2f", entry.currentActual))
                            .foregroundColor(.primary)
                            .frame(width: 100, alignment: .trailing)
                        Text(trendSymbol(entry.previousActual, entry.currentActual))
                            .foregroundColor(.primary)
                            .frame(width: 40, alignment: .center)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(AppSettings.shared.sectionBoxColor)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .background(Color.clear)
        }
    }
}

struct ExpenseCategoryGridView: View {
    let expenseCategories: [String: [MonthlyComparisonEntryV4]]
    let sortedCategories: [String]
    let trendSymbol: (Double, Double) -> String

    var body: some View {
        Text("Expenses")
            .font(.title2)
            .bold()
            .foregroundColor(.primary)
            .padding(.leading)
        // 2-column grid for categories
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            alignment: .leading,
            spacing: 24
        ) {
            ForEach(sortedCategories, id: \.self) { cat in
                categoryView(for: cat)
            }
        }
        .padding(.horizontal)
        .background(Color.clear)
    }

    @ViewBuilder
    private func categoryView(for cat: String) -> some View {
        let entries = expenseCategories[cat] ?? []
        VStack(alignment: .leading, spacing: 12) {
            Text(cat)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 2)
            // Table header
            HStack {
                Text("Name")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Budgeted")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 80, alignment: .trailing)
                Spacer(minLength: 12)
                Text("Previous Actual")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 80, alignment: .trailing)
                Spacer(minLength: 12)
                Text("Current Actual")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 80, alignment: .trailing)
                Spacer(minLength: 12)
                Text("Trend")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .frame(width: 40, alignment: .center)
                Spacer(minLength: 16)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .background(AppSettings.shared.sectionBoxColor.opacity(0.6))
            .cornerRadius(6)
            ForEach(entries) { entry in
                entryRow(for: entry)
            }
        }
        .padding(8)
        .background(AppSettings.shared.sectionBoxColor.opacity(0.25))
        .cornerRadius(10)
    }

    @ViewBuilder
    private func entryRow(for entry: MonthlyComparisonEntryV4) -> some View {
        HStack {
            Text(entry.name)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(String(format: "%.2f", entry.budgeted))
                .foregroundColor(.primary)
                .frame(width: 80, alignment: .trailing)
            Spacer(minLength: 12)
            Text(String(format: "%.2f", entry.previousActual))
                .foregroundColor(.primary)
                .frame(width: 80, alignment: .trailing)
            Spacer(minLength: 12)
            Text(String(format: "%.2f", entry.currentActual))
                .foregroundColor(.primary)
                .frame(width: 80, alignment: .trailing)
            Spacer(minLength: 12)
            Text(trendSymbol(entry.previousActual, entry.currentActual))
                .foregroundColor(.primary)
                .frame(width: 40, alignment: .center)
            Spacer(minLength: 16)
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 4)
        .background(AppSettings.shared.sectionBoxColor)
        .cornerRadius(6)
    }
}

// MARK: - Uniquely Named Struct for Monthly Actual Entry (V2)
struct MonthlyActualEntryV2: Identifiable, Codable {
    var id: UUID
    var name: String
    var categoryName: String
    var budgetedAmount: Double
    var actualAmount: Double

    enum CodingKeys: String, CodingKey {
        case id, name, categoryName, budgetedAmount, actualAmount
    }
}
