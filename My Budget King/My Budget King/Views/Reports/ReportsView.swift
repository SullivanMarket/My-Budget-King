//
//  ReportsView.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI
import UniformTypeIdentifiers

struct ReportsView: View {
    @State private var actuals: [ReportMonthlyActualEntry] = []
    @State private var groupedExpenses: [String: [ReportMonthlyActualEntry]] = [:]
    @State private var selectedType: AppBudgetType = .personal
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @ObservedObject private var settings = AppSettings.shared

    private let orderedExpenseCategories = [
        "Housing", "Transportation", "Insurance", "Food", "Children", "Legal",
        "Savings/Investments", "Loans", "Entertainment", "Taxes", "Personal Care",
        "Pets", "Gifts and Donations"
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reports")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)

                    Text("Viewing actual results for \(selectedType.rawValue.capitalized) budget in \(String(selectedYear))")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Spacer()

                Button(action: {
                    generateRtfPreview()
                }) {
                    Label("Export RTF", systemImage: "doc.richtext")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .foregroundColor(.primary)

                Text("Budget Type")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.leading, 8)

                Picker("", selection: $selectedType) {
                    Text("Personal").tag(AppBudgetType.personal)
                    Text("Family").tag(AppBudgetType.family)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }
            .padding()
            .background(settings.headerColor)
                
                // START SCROLLVIEW
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // ✅ Correct Income Section (ONLY ONCE)
                        if !actuals.filter({ $0.category.lowercased() == "income" }).isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Income")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 4)

                                VStack(spacing: 8) {
                                    ForEach(actuals.filter { $0.category.lowercased() == "income" }, id: \.id) { entry in
                                        ReportRow(entry: entry, isIncome: true)
                                    }
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 12).fill(settings.sectionBoxColor))
                            }
                            .padding(.horizontal)
                        }

                    // Expenses Section
                    Text("Expenses")
                        .font(.title2) // H2-like size (larger than headline)
                            .bold()        // Make it bold
                            .foregroundColor(.primary)
                            .padding(.bottom, 4)
                        .padding(.vertical, 4)

                    let leftColumnCategories = stride(from: 0, to: orderedExpenseCategories.count, by: 2).map { orderedExpenseCategories[$0] }
                    let rightColumnCategories = stride(from: 1, to: orderedExpenseCategories.count, by: 2).map { orderedExpenseCategories[$0] }

                    HStack(alignment: .top, spacing: 24) {
                        // Left Column
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(leftColumnCategories, id: \.self) { category in
                                if let entries = groupedExpenses[category], !entries.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(category)
                                            .font(.subheadline)
                                            .bold()

                                        ForEach(entries, id: \.id) { entry in
                                            ReportRow(entry: entry, isIncome: false)
                                        }
                                    }
                                    .padding()
                                    .background(settings.sectionBoxColor)
                                    .cornerRadius(10)
                                }
                            }
                        }

                        // Right Column
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(rightColumnCategories, id: \.self) { category in
                                if let entries = groupedExpenses[category], !entries.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(category)
                                            .font(.subheadline)
                                            .bold()

                                        ForEach(entries, id: \.id) { entry in
                                            ReportRow(entry: entry, isIncome: false)
                                        }
                                    }
                                    .padding()
                                    .background(settings.sectionBoxColor)
                                    .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .background(settings.sectionBoxColor)
            .ifLet(settings.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
        }
        .onAppear(perform: loadActualDataForReports)
    }

    private func loadActualDataForReports() {
        let (all, grouped) = BudgetDataManager.shared.loadGroupedActualsForReports(for: selectedYear, type: selectedType)
        actuals = all
        groupedExpenses = grouped
    }

    private func generateRtfPreview() {
        print("Generating RTF...")

        let rtfContent = DocxExporter.shared.createFormattedRtf(
            actuals: actuals,
            groupedExpenses: groupedExpenses,
            selectedType: selectedType,
            selectedYear: selectedYear
        )

        if let data = rtfContent.data(using: .utf8) {
            saveDocxToFile(data: data)
            print("✅ RTF saved successfully.")
        } else {
            print("❌ Failed to create RTF data.")
        }
    }

    private func saveDocxToFile(data: Data) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.rtf]
        panel.nameFieldStringValue = "BudgetReport.rtf"

        if panel.runModal() == .OK, let url = panel.url {
            do {
                try data.write(to: url)
                print("✅ File saved successfully: \(url)")
            } catch {
                print("❌ Failed to save file: \(error)")
            }
        }
    }
}

// MARK: - ReportRow View

struct ReportRow: View {
    var entry: ReportMonthlyActualEntry
    var isIncome: Bool
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        HStack {
            Text(entry.name)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Text(String(format: "$%.2f", entry.budgetedAmount))
                .frame(width: 80, alignment: .trailing)

            Spacer(minLength: 8)

            Text(String(format: "$%.2f", entry.actualAmount))
                .frame(width: 80, alignment: .trailing)

            Spacer(minLength: 8)

            trendIcon(for: entry)
                .frame(width: 20)
        }
        .padding(8)
        .background(settings.fieldRowColor)
        .cornerRadius(8)
    }

    private func trendIcon(for entry: ReportMonthlyActualEntry) -> some View {
        let actual = entry.actualAmount
        let budgeted = entry.budgetedAmount

        if actual == budgeted {
            return Image(systemName: "equal")
                .foregroundColor(.green)
                .bold()
        } else if isIncome {
            return Image(systemName: actual > budgeted ? "arrow.up" : "arrow.down")
                .foregroundColor(actual > budgeted ? .green : .red)
                .bold()
        } else {
            return Image(systemName: actual > budgeted ? "arrow.up" : "arrow.down")
                .foregroundColor(actual > budgeted ? .red : .green)
                .bold()
        }
    }
}
