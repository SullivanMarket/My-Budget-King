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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if isEditable {
                    // NAME FIELD
                    TextField("Name", text: $item.name)
                        .padding(6)
                        .frame(height: 30)
                        .background(isEditable ? Color.white : settings.fieldRowColor)
                        .cornerRadius(6)
                        .foregroundColor(.primary)

                    Spacer()

                    // AMOUNT FIELD
                    TextField("Amount", value: $item.amount, format: .number)
                        .padding(6)
                        .frame(width: 80, height: 30)
                        .background(isEditable ? Color.white : settings.fieldRowColor)
                        .cornerRadius(6)
                        .foregroundColor(.primary)
                } else {
                    Text(item.name)
                        .foregroundColor(.primary)

                    Spacer()

                    Text(String(format: "%.2f", item.amount))
                        .frame(width: 80, alignment: .trailing)
                        .foregroundColor(.primary)
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
                    .buttonStyle(.plain)
                }
            }

            // ✅ DEBUG BLOCK
            if isEditable {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Debug Field (should be white):")
                        .font(.caption)
                        .foregroundColor(.primary)

                    TextField("Test Amount", value: .constant(123.45), format: .number)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(6)
                        .foregroundColor(.primary)
                        .frame(width: 120)
                }
            }
        }
        .padding(6)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(8)
    }
}
