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
    case comparison = "Monthly Comparison"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .setup: return "pencil.and.outline"
        case .actuals: return "doc.plaintext"
        case .reports: return "chart.bar"
        case .comparison: return "doc.text.magnifyingglass"
        }
    }
}

struct MainAppView: View {
    @State private var selectedPage: AppPage? = .setup
    @ObservedObject private var settings = AppSettings.shared
    @State private var showingSettings = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(AppPage.allCases, selection: $selectedPage) { page in
                    Button(action: {
                        selectedPage = page
                    }) {
                        Label(page.rawValue, systemImage: page.icon)
                            .foregroundColor(selectedPage == page ? .white : .primary)
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedPage == page ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .foregroundColor(.white)
                    .padding(8)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
                .sheet(isPresented: $showingSettings) {
                    SettingsPopupView()
                }
            }
            .padding()
            .background(Color("SidebarBackground"))
        } detail: {
            switch selectedPage {
            case .setup:
                BudgetSetupView()
            case .actuals:
                MonthlyActualsView()
            case .reports:
                ReportsView()
            case .comparison:
                MonthlyComparisonPage()
            case .none:
                Text("Select a page")
            }
        }
        .navigationSplitViewStyle(.balanced)
        .frame(minWidth: 1000, minHeight: 700)
        .preferredColorScheme(settings.preferredColorScheme)
    }
}
