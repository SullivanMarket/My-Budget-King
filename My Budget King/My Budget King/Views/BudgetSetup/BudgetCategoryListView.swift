//
//  BudgetCategoryListView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI

struct BudgetCategoryListView: View {
    @Binding var categories: [BudgetCategory]
    var selectedYear: Int
    var selectedType: AppBudgetType
    var isEditable: Bool

    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        Text("Income")
            .font(.title2)
            .bold()
            .foregroundColor(.primary)
            .padding(.bottom, 4)

        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                renderIncomeSection()

                Text("Expenses")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding(.bottom, 4)

                renderExpensesSection()
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private func renderIncomeSection() -> some View {
        if let incomeCategory = categories.first(where: { $0.name.lowercased() == "income" }),
           let incomeIndex = categories.firstIndex(where: { $0.id == incomeCategory.id }) {

            VStack(alignment: .leading, spacing: 8) {
                VStack(spacing: 8) {
                    ForEach(categories[incomeIndex].items.indices, id: \.self) { i in
                        BudgetItemRowView(
                            item: $categories[incomeIndex].items[i],
                            isEditable: isEditable,
                            onDelete: { itemId in
                                if let itemIndex = categories[incomeIndex].items.firstIndex(where: { $0.id == itemId }) {
                                    categories[incomeIndex].items.remove(at: itemIndex)
                                }
                            }
                        )
                        .background(settings.fieldRowColor)
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).fill(settings.sectionBoxColor))
            }
            .padding(.horizontal)
        }
    }

    @ViewBuilder
    private func renderExpensesSection() -> some View {
        let order = ["Housing", "Transportation", "Insurance", "Food", "Children", "Legal", "Savings/Investments", "Loans", "Entertainment", "Taxes", "Personal Care", "Pets", "Gifts and Donations"]

        let expenses = categories
            .filter { $0.name.lowercased() != "income" }
            .sorted {
                (order.firstIndex(of: $0.name) ?? Int.max) < (order.firstIndex(of: $1.name) ?? Int.max)
            }

        let leftColumn = stride(from: 0, to: expenses.count, by: 2).map { expenses[$0] }
        let rightColumn = stride(from: 1, to: expenses.count, by: 2).map { expenses[$0] }

        HStack(alignment: .top, spacing: 24) {
            VStack(spacing: 20) {
                ForEach(leftColumn, id: \.id) { category in
                    renderCategorySection(category: category)
                }
            }

            VStack(spacing: 20) {
                ForEach(rightColumn, id: \.id) { category in
                    renderCategorySection(category: category)
                }
            }
        }
    }

    @ViewBuilder
    private func renderCategorySection(category: BudgetCategory) -> some View {
        if let categoryIndex = categories.firstIndex(where: { $0.id == category.id }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(category.name)
                    .sectionHeaderStyle()
                    .padding(.top, 8)

                ForEach(categories[categoryIndex].items.indices, id: \.self) { i in
                    BudgetItemRowView(
                        item: $categories[categoryIndex].items[i],
                        isEditable: isEditable,
                        onDelete: { itemId in
                            if let itemIndex = categories[categoryIndex].items.firstIndex(where: { $0.id == itemId }) {
                                categories[categoryIndex].items.remove(at: itemIndex)
                            }
                        }
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
