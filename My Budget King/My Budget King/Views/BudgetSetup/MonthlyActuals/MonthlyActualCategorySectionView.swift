//
//  MonthlyActualCategorySectionView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI

struct MonthlyActualCategorySectionView: View {
    @Binding var item: MonthlyActualEntry
    var isEditable: Bool

    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach($item.items) { $actualItem in
                HStack {
                    Text(actualItem.name)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text(String(format: "%.2f", actualItem.budgeted))
                        .frame(width: 60, alignment: .trailing)

                    if isEditable {
                        TextField("Actual", value: $actualItem.actual, format: .number)
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(String(format: "%.2f", actualItem.actual))
                            .frame(width: 60, alignment: .trailing)
                    }
                }
                .padding(6)
                .background(settings.fieldRowColor)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(settings.sectionBoxColor)
        .cornerRadius(10)
    }
}
