//
//  MonthlyActualItemRow.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI

struct MonthlyActualItemRowView: View {   // <-- IMPORTANT NAME
    @Binding var item: MonthlyActualItem
    var isEditable: Bool

    var body: some View {
        HStack {
            Text(item.name)
                .font(.subheadline)
            Spacer()
            if isEditable {
                TextField("Actual", value: $item.actual, format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)
            } else {
                Text("$\(item.actual, specifier: "%.2f")")
                    .font(.subheadline)
            }
        }
    }
}
