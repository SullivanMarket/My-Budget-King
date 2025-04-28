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
                if let incomeCategory = categories.first(where: { $0.name.lowercased() == "income" }) {
                    if let incomeIndex = categories.firstIndex(where: { $0.id == incomeCategory.id }) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Blue box starts here
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

                let expenses = categories
                    .filter { $0.name.lowercased() != "income" } // Use 'name' instead of 'categoryName'
                    .sorted { category1, category2 in
                        let order = ["Housing", "Transportation", "Insurance", "Food", "Children", "Legal", "Savings/Investments", "Loans", "Entertainment", "Taxes", "Personal Care", "Pets", "Gifts and Donations"]
                        
                        let index1 = order.firstIndex(of: category1.name) ?? 0
                        let index2 = order.firstIndex(of: category2.name) ?? 0
                        
                        return index1 < index2
                    }

                Text("Expenses")
                    .font(.title2) // H2-like size (larger than headline)
                        .bold()        // Make it bold
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)

                let leftColumn = stride(from: 0, to: expenses.count, by: 2).map { expenses[$0] }
                let rightColumn = stride(from: 1, to: expenses.count, by: 2).map { expenses[$0] }

                HStack(alignment: .top, spacing: 24) {
                    VStack(spacing: 20) {
                        ForEach(leftColumn, id: \.id) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.name)
                                    .sectionHeaderStyle()
                                    .padding(.top, 8)

                                ForEach(category.items.indices, id: \.self) { i in
                                    BudgetItemRowView(
                                        item: $categories[categories.firstIndex(where: { $0.id == category.id })!].items[i],
                                        isEditable: isEditable,
                                        onDelete: { itemId in
                                            if let itemIndex = category.items.firstIndex(where: { $0.id == itemId }) {
                                                categories[categories.firstIndex(where: { $0.id == category.id })!].items.remove(at: itemIndex)
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

                    VStack(spacing: 20) {
                        ForEach(rightColumn, id: \.id) { category in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(category.name)
                                    .sectionHeaderStyle()
                                    .padding(.top, 8)

                                ForEach(category.items.indices, id: \.self) { i in
                                    BudgetItemRowView(
                                        item: $categories[categories.firstIndex(where: { $0.id == category.id })!].items[i],
                                        isEditable: isEditable,
                                        onDelete: { itemId in
                                            if let itemIndex = category.items.firstIndex(where: { $0.id == itemId }) {
                                                categories[categories.firstIndex(where: { $0.id == category.id })!].items.remove(at: itemIndex)
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
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
    }
}
