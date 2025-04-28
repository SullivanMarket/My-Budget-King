//
//  MonthlyActualCategoryListView.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI

struct MonthlyActualCategoryListView: View {
    @Binding var actuals: [MonthlyActualEntry]
    var selectedYear: Int
    var selectedType: AppBudgetType
    var isEditable: Bool

    @ObservedObject private var settings = AppSettings.shared

    private let orderedExpenseCategories = [
        "Housing", "Transportation", "Insurance", "Food", "Children", "Legal",
        "Savings/Investments", "Loans", "Entertainment", "Taxes", "Personal Care",
        "Pets", "Gifts and Donations"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Income Section
            if let incomeCategory = actuals.first(where: { $0.categoryName.lowercased() == "income" }) {
                Text("Income")
                    .font(.title2) // H2-like size (larger than headline)
                        .bold()        // Make it bold
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                
                VStack(alignment: .leading, spacing: 8) {

                    ForEach(incomeCategory.items.indices, id: \.self) { i in
                        MonthlyActualItemRowView(
                            item: $actuals[actuals.firstIndex(where: { $0.id == incomeCategory.id })!].items[i],
                            isEditable: isEditable
                        )
                        .padding(6)
                        .background(settings.fieldRowColor)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(settings.sectionBoxColor))
            }

            // Expenses Section
            let expenses = actuals.filter { $0.categoryName.lowercased() != "income" }.sorted {
                orderedExpenseCategories.firstIndex(of: $0.categoryName) ?? 0 <
                orderedExpenseCategories.firstIndex(of: $1.categoryName) ?? 0
            }
            let leftColumn = stride(from: 0, to: expenses.count, by: 2).map { expenses[$0] }
            let rightColumn = stride(from: 1, to: expenses.count, by: 2).map { expenses[$0] }

            Text("Expenses")
                .font(.title2) // H2-like size (larger than headline)
                    .bold()        // Make it bold
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)
                .padding(.top, 16)

            HStack(alignment: .top, spacing: 24) {
                VStack(spacing: 20) {
                    ForEach(leftColumn, id: \.id) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.categoryName)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.primary)

                            ForEach(category.items.indices, id: \.self) { i in
                                MonthlyActualItemRowView(
                                    item: $actuals[actuals.firstIndex(where: { $0.id == category.id })!].items[i],
                                    isEditable: isEditable
                                )
                                .padding(6)
                                .background(settings.fieldRowColor)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(settings.sectionBoxColor))
                    }
                }

                VStack(spacing: 20) {
                    ForEach(rightColumn, id: \.id) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.categoryName)
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.primary)

                            ForEach(category.items.indices, id: \.self) { i in
                                MonthlyActualItemRowView(
                                    item: $actuals[actuals.firstIndex(where: { $0.id == category.id })!].items[i],
                                    isEditable: isEditable
                                )
                                .padding(6)
                                .background(settings.fieldRowColor)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(settings.sectionBoxColor))
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}
