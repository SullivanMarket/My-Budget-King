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
    var onDelete: (UUID) -> Void  // 🔧 Fix: accepts item ID now

    var body: some View {
        HStack {
            if isEditable {
                TextField("Name", text: $item.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Amount", value: $item.amount, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    onDelete(item.id)  // ✅ Pass item ID here
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                Text(item.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                Text(String(format: "%.2f", item.amount))
                    .frame(alignment: .trailing)
            }
        }
        .padding(.horizontal)
    }
}
