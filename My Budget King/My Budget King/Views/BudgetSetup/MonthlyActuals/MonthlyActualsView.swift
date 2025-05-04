//
//  MonthlyActualsView.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI
import Foundation

struct MonthlyActualsView: View {
    struct MonthlyActualItemFinalLocal: Identifiable, Codable {
        var id: UUID
        var name: String
        var budgeted: Double
        var actual: Double
    }

    struct MonthlyActualCategoryFinalLocal: Identifiable, Codable {
        var id: UUID
        var name: String
        var items: [MonthlyActualItemFinalLocal]
    }

    @State private var entries: [MonthlyActualCategoryFinalLocal] = []
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedType: AppBudgetType = .personal
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.colorScheme) private var colorScheme

    private var adjustedTextColor: Color {
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
            }
        }
        .background(settings.sectionBoxColor)
        .onAppear {
            print("🌗 MonthlyActualsView is in \(colorScheme == .dark ? "Dark" : "Light") Mode")
            loadMonthlyActuals()
        }
        .onChange(of: selectedMonth) {
            loadMonthlyActuals()
        }
        .onChange(of: selectedType) {
            loadMonthlyActuals()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Monthly Actuals").font(.title).bold()
                Text("Enter your real expenses and income for each month.")
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
            Button(action: saveMonthlyActuals) {
                Label("Save", systemImage: "externaldrive.fill")
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white)
                    .foregroundColor(.primary)
                    .cornerRadius(12)
            }.buttonStyle(PlainButtonStyle())
        }.padding().background(settings.headerColor)
    }

    private var incomeSection: some View {
        Group {
            if let income = entries.first(where: { $0.name == "Income" }) {
                VStack(alignment: .leading, spacing: 4) {
                    // Move "Income" OUTSIDE the green background
                    Text("Income")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal, 8)
                        .foregroundColor(adjustedTextColor)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(income.items.indices, id: \.self) { index in
                            itemRow(for: income.items[index], binding: $entries[getIndex(of: income)].items[index])
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(settings.sectionBoxColor)
                    )
                }
            }
        }
    }

    private var expenseSection: some View {
        let expenses = entries.filter { $0.name != "Income" }
        let sorted = orderedExpenseCategories.compactMap { name in
            expenses.first(where: { $0.name == name })
        }
        let mid = Int(ceil(Double(sorted.count) / 2.0))
        let left = sorted.prefix(mid)
        let right = sorted.suffix(from: mid)

        return VStack(alignment: .leading, spacing: 16) {
            Text("Expenses")
                .font(.title2)
                .bold()
                .foregroundColor(adjustedTextColor)
                .padding(.top, 12)
                .padding(.bottom, 4)

            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(Array(left)) { category in
                        categorySection(category)
                    }
                }
                VStack(alignment: .leading, spacing: 24) {
                    ForEach(Array(right)) { category in
                        categorySection(category)
                    }
                }
            }
        }
    }

    private func categorySection(_ category: MonthlyActualCategoryFinalLocal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name).font(.headline).bold().foregroundColor(adjustedTextColor)
            ForEach(category.items.indices, id: \.self) { index in
                itemRow(for: category.items[index], binding: $entries[getIndex(of: category)].items[index])
            }
        }.padding().background(RoundedRectangle(cornerRadius: 12).fill(settings.sectionBoxColor))
    }

    private func itemRow(for item: MonthlyActualItemFinalLocal, binding: Binding<MonthlyActualItemFinalLocal>) -> some View {
        HStack {
            Text(item.name).frame(maxWidth: .infinity, alignment: .leading).foregroundColor(adjustedTextColor)
            Text(String(format: "%.2f", item.budgeted)).frame(width: 60, alignment: .trailing).foregroundColor(.secondary)
            TextField("Actual", value: binding.actual, formatter: NumberFormatter())
                .frame(width: 60, alignment: .trailing)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(6)
        .background(RoundedRectangle(cornerRadius: 8).fill(settings.fieldRowColor))
    }

    private func getIndex(of category: MonthlyActualCategoryFinalLocal) -> Int {
        entries.firstIndex(where: { $0.id == category.id }) ?? 0
    }

    private func loadMonthlyActuals() {
        let filename = String(format: "%02d-%04d-actuals.json", selectedMonth, Calendar.current.component(.year, from: Date()))
        guard let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(filename),
              let data = try? Data(contentsOf: url) else {
            print("❌ Failed to load monthly actual entries for \(selectedMonth)/2025")
            return
        }

        struct FlatEntry: Codable {
            var id: UUID
            var name: String
            var categoryName: String
            var budgetedAmount: Double
            var actualAmount: Double
        }

        do {
            let flatEntries = try JSONDecoder().decode([FlatEntry].self, from: data)
            let grouped = Dictionary(grouping: flatEntries, by: { $0.categoryName })
            let allCategoryNames = ["Income"] + orderedExpenseCategories
            entries = allCategoryNames.compactMap { name in
                guard let items = grouped[name] else { return nil }
                let mapped = items.map { MonthlyActualItemFinalLocal(id: $0.id, name: $0.name, budgeted: $0.budgetedAmount, actual: $0.actualAmount) }
                return MonthlyActualCategoryFinalLocal(id: UUID(), name: name, items: mapped)
            }
        } catch {
            print("❌ Decoding error: \(error)")
        }
    }

    private func saveMonthlyActuals() {
        let toSave = entries.flatMap { category in
            category.items.map { item in
                MonthlyActualFlatEntry(
                    id: item.id,
                    name: item.name,
                    categoryName: category.name,
                    budgetedAmount: item.budgeted,
                    actualAmount: item.actual
                )
            }
        }
        BudgetDataManager.shared.saveMonthlyActuals(toSave, for: selectedMonth, year: Calendar.current.component(.year, from: Date()), type: selectedType)
    }
}
