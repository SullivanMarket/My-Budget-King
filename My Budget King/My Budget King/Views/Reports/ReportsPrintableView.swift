//
//  ReportsPrintableView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI

struct ReportsPrintableView: View {
    let actuals: [MonthlyActualEntry]
    let selectedType: AppBudgetType
    let selectedYear: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("\(selectedType.rawValue.capitalized) Budget Report – \(String(selectedYear))")
                .font(.title)
                .bold()

            if let income = actuals.first(where: { $0.categoryName.lowercased() == "income" }) {
                Text("Income")
                    .font(.title2) // H2-like size (larger than headline)
                        .bold()        // Make it bold
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    .padding(.top, 8) // 🔥 Adds buffer above "Income"

                VStack(spacing: 4) {
                    ForEach(income.items) { item in
                        HStack {
                            Text(item.name)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text(String(format: "%.2f", item.budgeted))
                                .frame(width: 80, alignment: .trailing)

                            Text(String(format: "%.2f", item.actual))
                                .frame(width: 80, alignment: .trailing)

                            Group {
                                if item.actual > item.budgeted {
                                    Image(systemName: "arrow.up").foregroundColor(.green)
                                } else if item.actual < item.budgeted {
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
            }

            let expenseEntries = actuals.filter { $0.categoryName.lowercased() != "income" }.sorted {
                let order = ["Housing", "Transportation", "Insurance", "Food", "Children", "Legal", "Savings/Investments", "Loans", "Entertainment", "Taxes", "Personal Care", "Pets", "Gifts and Donations"]
                return order.firstIndex(of: $0.categoryName) ?? 0 < order.firstIndex(of: $1.categoryName) ?? 0
            }

            if !actuals.isEmpty {
                Text("Expenses")
                    .font(.title2) // H2-like size (larger than headline)
                        .bold()        // Make it bold
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    .padding(.top)

                ForEach(actuals) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.categoryName)
                            .font(.subheadline)
                            .bold()

                        ForEach(entry.items) { item in
                            HStack {
                                Text(item.name)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Text(String(format: "%.2f", item.budgeted))
                                    .frame(width: 80, alignment: .trailing)

                                Text(String(format: "%.2f", item.actual))
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

            Spacer()
        }
        .padding()
        .frame(width: 612, height: 792) // US Letter
    }
}
