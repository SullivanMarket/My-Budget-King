//
//  MonthlyActualItemRow.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI

struct MonthlyActualItemRow: View {
    var item: MonthlyActualItemScoped
    @Binding var actualAmount: Double
    var isEditable: Bool
    var textColor: Color = .primary  // Optional parameter for dark/light support

    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(settings.fieldRowColor)
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary, lineWidth: 0.5)

            HStack(spacing: 16) {
                Text(item.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(textColor)
                    .padding(.leading, 6)

                Text(String(format: "%.2f", item.budgetedAmount))
                    .frame(width: 80, alignment: .trailing)
                    .foregroundColor(.secondary)

                TextField("Actual", value: $actualAmount, formatter: NumberFormatter())
                    .frame(width: 80, alignment: .trailing)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing, 4)
            }
            .frame(minHeight: 36)
            .padding(.vertical, 4)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
