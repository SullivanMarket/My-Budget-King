//
//  MonthlyActualItemScopedView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI

struct MonthlyActualItemScoped: Identifiable, Codable {
    var id: UUID
    var name: String
    var budgetedAmount: Double
    var actualAmount: Double
}

struct MonthlyActualCategorySectionView: View {
    @Binding var items: [MonthlyActualItemScoped]
    var categoryName: String
    var isEditable: Bool
    var textColor: Color

    var body: some View {
        Section(header:
            Text(categoryName)
                .font(.headline)
                .bold()
                .padding(.bottom, 4)
                .foregroundColor(textColor)
        ) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let actualBinding = Binding<Double>(
                    get: { item.actualAmount },
                    set: { newValue in
                        if isEditable {
                            items[index].actualAmount = newValue
                        }
                    }
                )

                MonthlyActualItemRow(
                    item: item,
                    actualAmount: actualBinding,
                    isEditable: isEditable,
                    textColor: textColor
                )
            }
        }
    }
}

// Expense category sort order used for consistent rendering
typealias ExpenseCategoryOrder = [String]
let orderedExpenseCategories: ExpenseCategoryOrder = [
    "Housing",
    "Transportation",
    "Insurance",
    "Food",
    "Children",
    "Legal",
    "Savings/Investments",
    "Loans",
    "Entertainment",
    "Taxes",
    "Personal Care",
    "Pets",
    "Gifts and Donations"
]
