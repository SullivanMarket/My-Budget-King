//
//  BudgetSetupView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import SwiftUI

struct BudgetSetupView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedType: AppBudgetType = .personal
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var categories: [BudgetCategory] = []
    @State private var showAlert = false
    @State private var isEditing = false
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Budget Setup")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)

                    Text("Setting up \(selectedType.rawValue.capitalized) budget for \(String(selectedYear))")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                }
                Spacer()

                Text("Budget Type")
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Picker("", selection: $selectedType) {
                    Text("Personal").tag(AppBudgetType.personal)
                    Text("Family").tag(AppBudgetType.family)
                }
                .pickerStyle(.segmented)
                .frame(width: 160)

                Button(action: {
                    loadDefaults()
                }) {
                    Label("Load Defaults", systemImage: "arrow.down.circle")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    loadSaved()
                }) {
                    Label("Load Saved", systemImage: "folder")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    saveBudget()
                }) {
                    Label("Save", systemImage: "externaldrive.fill")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(colorScheme == .dark ? Color.black : Color.white)
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            .background(settings.headerColor)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Income Section
                    Text("Income")
                        .font(.title2) // H2-like size (larger than headline)
                        .bold()        // Make it bold
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    if let incomeCategory = categories.first(where: { $0.name.lowercased() == "income" }) {
                        VStack(alignment: .leading, spacing: 8) {

                            ForEach(incomeCategory.items.indices, id: \.self) { i in
                                HStack {
                                    if isEditing {
                                        TextField("Name", text: $categories[categories.firstIndex(where: { $0.id == incomeCategory.id })!].items[i].name)
                                            .textFieldStyle(.roundedBorder)
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        Text(incomeCategory.items[i].name)
                                    }
                                    Spacer()
                                    if isEditing {
                                        TextField("Amount", value: $categories[categories.firstIndex(where: { $0.id == incomeCategory.id })!].items[i].amount, format: .number)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .frame(width: 100)
                                    } else {
                                        Text(String(format: "$%.2f", incomeCategory.items[i].amount))
                                    }
                                }
                                .padding(8)
                                .background(settings.fieldRowColor)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(settings.sectionBoxColor)
                        .cornerRadius(12)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(settings.sectionBoxColor))
                    }

                    // Expenses Section
                    let expenses = categories.filter { $0.name.lowercased() != "income" }
                    let leftColumn = stride(from: 0, to: expenses.count, by: 2).map { expenses[$0] }
                    let rightColumn = stride(from: 1, to: expenses.count, by: 2).map { expenses[$0] }

                    Text("Expenses")
                        .font(.title2) // H2-like size (larger than headline)
                            .bold()        // Make it bold
                            .foregroundColor(.primary)
                            .padding(.bottom, 4)
                        .padding(.top, 8)

                    HStack(alignment: .top, spacing: 24) {
                        VStack(spacing: 20) {
                            ForEach(leftColumn) { category in
                                ExpenseCategorySection(category: binding(for: category), isEditing: isEditing)
                            }
                        }

                        VStack(spacing: 20) {
                            ForEach(rightColumn) { category in
                                ExpenseCategorySection(category: binding(for: category), isEditing: isEditing)
                            }
                        }
                    }
                }
                .padding()
            }
            .background(settings.sectionBoxColor)
            .ifLet(settings.colorScheme) { view, scheme in
                view.colorScheme(scheme)
            }
        }
        .onAppear {
            loadSaved()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Saved!"), message: Text("Your budget was saved successfully."), dismissButton: .default(Text("OK")))
        }
    }

    private func loadDefaults() {
        categories = BudgetDataManager.shared.loadDefaultCategories(for: selectedType)
    }

    private func loadSaved() {
        categories = BudgetDataManager.shared.loadMonthlyBudgets(for: selectedYear, type: selectedType)
    }

    private func saveBudget() {
        BudgetDataManager.shared.saveMonthlyBudgets(categories, for: selectedYear, type: selectedType)
        showAlert = true
    }

    private func binding(for category: BudgetCategory) -> Binding<BudgetCategory> {
        guard let index = categories.firstIndex(where: { $0.id == category.id }) else {
            fatalError("Category not found")
        }
        return $categories[index]
    }
}

struct ExpenseCategorySection: View {
    @Binding var category: BudgetCategory
    var isEditing: Bool
    @ObservedObject private var settings = AppSettings.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(category.name)
                .font(.headline)
                .padding(.vertical, 4)

            ForEach(category.items.indices, id: \.self) { i in
                HStack {
                    if isEditing {
                        TextField("Name", text: $category.items[i].name)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text(category.items[i].name)
                    }
                    Spacer()
                    if isEditing {
                        TextField("Amount", value: $category.items[i].amount, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    } else {
                        Text(String(format: "$%.2f", category.items[i].amount))
                    }
                }
                .padding(8)
                .background(settings.fieldRowColor)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(settings.sectionBoxColor)
        .cornerRadius(12)
    }
}

extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ optional: T?, transform: (Self, T) -> Content) -> some View {
        if let value = optional {
            transform(self, value)
        } else {
            self
        }
    }
}
