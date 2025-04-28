//
//  MainAppView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import SwiftUI

enum AppPage: String, CaseIterable, Identifiable {
    case setup = "Budget Setup"
    case actuals = "Monthly Actuals"
    case reports = "Reports"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .setup: return "pencil.and.list.clipboard"
        case .actuals: return "calendar.badge.clock"
        case .reports: return "chart.bar.xaxis"
        }
    }
}

struct MainAppView: View {
    @State private var selectedPage: AppPage? = .setup
    @State private var showingSettings = false

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(AppPage.allCases, selection: $selectedPage) { page in
                    Button {
                        selectedPage = page
                    } label: {
                        Label(page.rawValue, systemImage: page.icon)
                            .font(.body)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .tag(page)
                }

                Divider()

                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Spacer()
                        Label("Settings", systemImage: "gearshape")
                            .font(.body)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                    .contentShape(Rectangle()) // <-- move this INSIDE here!
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .foregroundColor(.primary)
            }
            .frame(minWidth: 200)
        } detail: {
            switch selectedPage {
            case .setup:
                BudgetSetupView()
            case .actuals:
                MonthlyActualsView()
            case .reports:
                ReportsView()
            case .none:
                Text("Please select a page")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsPopupView()
        }
        .navigationSplitViewStyle(.balanced)
        .navigationTitle("My Budget King :: \(selectedPage?.rawValue ?? "")")
    }
}
