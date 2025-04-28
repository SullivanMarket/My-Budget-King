//
//  MonthlyActualsView.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI

struct MonthlyActualsView: View {
    @State private var entries: [MonthlyActualEntry] = []
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    @State private var selectedType: AppBudgetType = .personal
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        VStack(spacing: 0) {
            // HEADER AREA
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monthly Actuals")
                            .font(.title)
                            .bold()
                            .foregroundColor(.primary)
                        Text("Enter your real expenses and income for each month.")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Month")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Picker("Month", selection: $selectedMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text(Calendar.current.monthSymbols[month - 1])
                                        .tag(month)
                                }
                            }
                            .labelsHidden()
                            .frame(width: 120)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Budget Type")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Picker("", selection: $selectedType) {
                                Text("Personal").tag(AppBudgetType.personal)
                                Text("Family").tag(AppBudgetType.family)
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 160)
                        }
                    }

                    Button(action: {
                        saveMonthlyActuals()
                    }) {
                        Label("Save", systemImage: "externaldrive.fill")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
            }
            .background(settings.headerColor) // ✅ Correct - header only!

            // BODY AREA
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    MonthlyActualCategoryListView(
                        actuals: $entries,
                        selectedYear: Calendar.current.component(.year, from: Date()),
                        selectedType: selectedType,
                        isEditable: true
                    )
                }
                .padding()
            }
            .background(settings.sectionBoxColor) // ✅ Only body uses section box color
        }
        .background(Color.clear) // No forced background behind everything
        .onAppear {
            loadMonthlyActuals()
        }
    }

    private func loadMonthlyActuals() {
        entries = BudgetDataManager.shared.loadMonthlyActuals(
            for: Calendar.current.component(.year, from: Date()),
            type: selectedType
        )
    }

    private func saveMonthlyActuals() {
        BudgetDataManager.shared.saveMonthlyActuals(
            entries,
            for: Calendar.current.component(.year, from: Date()),
            type: selectedType
        )
    }
}
