//
//  BudgetItemRowView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI

struct BudgetItemRowView: View {
    @Binding var item: BudgetItem
    var isEditable: Bool
    var onDelete: ((UUID) -> Void)? = nil

    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        HStack {
            if isEditable {
                TextField("Name", text: $item.name)
                Spacer()
                TextField("Amount", value: $item.amount, format: .number)
                    .frame(width: 80)
            } else {
                Text(item.name)
                Spacer()
                Text(String(format: "%.2f", item.amount))
                    .frame(width: 80, alignment: .trailing)
            }

            if isEditable {
                Button(action: {
                    withAnimation {
                        onDelete?(item.id)
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(6)
        .background(settings.fieldRowColor)
        .cornerRadius(8)
    }
}
