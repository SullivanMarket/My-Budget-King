//
//  ReportsPrintableView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI

struct ReportsPrintableView: View {
    let actuals: [MonthlyActualFlatEntry]
    let selectedType: AppBudgetType
    let selectedYear: Int

    var body: some View {
        content
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(selectedType.rawValue.capitalized) Budget Report – \(String(selectedYear))")
                .font(.title)
                .bold()

            let incomeEntries = actuals.filter { $0.categoryName.lowercased() == "income" }
            if !incomeEntries.isEmpty {
                // Move label above the colored box
                Text("Income")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.leading, 4)
                    .padding(.bottom, 4)

                VStack(spacing: 4) {
                    ForEach(incomeEntries) { item in
                        HStack {
                            Text(item.name)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(String(format: "$%.2f", item.budgetedAmount))
                                .frame(width: 80, alignment: .trailing)

                            Text(String(format: "$%.2f", item.actualAmount))
                                .frame(width: 80, alignment: .trailing)

                            Group {
                                if item.actualAmount > item.budgetedAmount {
                                    Image(systemName: "arrow.up").foregroundColor(.green)
                                } else if item.actualAmount < item.budgetedAmount {
                                    Image(systemName: "arrow.down").foregroundColor(.red)
                                } else {
                                    Image(systemName: "equal").foregroundColor(.green)
                                }
                            }
                        }
                        .padding(4)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                .padding()
                .background(AppSettings.shared.sectionBoxColor) // Wrap entries only
                .cornerRadius(12)
            }

            let expenseEntries = actuals.filter { $0.categoryName.lowercased() != "income" }
            let groupedExpenses = Dictionary(grouping: expenseEntries, by: { $0.categoryName })
            let order = ["Housing", "Transportation", "Insurance", "Food", "Children", "Legal", "Savings/Investments", "Loans", "Entertainment", "Taxes", "Personal Care", "Pets", "Gifts and Donations"]
            let sortedCategories = groupedExpenses.keys.sorted {
                (order.firstIndex(of: $0) ?? Int.max) < (order.firstIndex(of: $1) ?? Int.max)
            }

            if !sortedCategories.isEmpty {
                Text("Expenses")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
                    .padding(.top)

                ForEach(sortedCategories, id: \.self) { category in
                    if let items = groupedExpenses[category] {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category)
                                .font(.subheadline)
                                .bold()

                            ForEach(items) { item in
                                HStack {
                                    Text(item.name)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(String(format: "$%.2f", item.budgetedAmount))
                                        .frame(width: 80, alignment: .trailing)

                                    Text(String(format: "$%.2f", item.actualAmount))
                                        .frame(width: 80, alignment: .trailing)
                                }
                                .padding(4)
                                .background(Color.gray.opacity(0.08))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .frame(width: 612, height: 792) // US Letter
    }
}
