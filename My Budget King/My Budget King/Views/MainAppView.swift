//
//  MainAppView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/22/25.
//

import SwiftUI

// 🆕 Add this at the top before MainAppView
enum AppPage: String, CaseIterable, Identifiable {
    case setup = "Budget Setup"
    case actuals = "Monthly Actuals"
    case reports = "Reports"
    case comparison = "Monthly Comparison"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .setup: return "pencil.and.list.clipboard"
        case .actuals: return "calendar.badge.clock"
        case .reports: return "chart.bar.xaxis"
        case .comparison: return "chart.bar.doc.horizontal"
        }
    }
}

struct MainAppView: View {
    @State private var selectedPage: AppPage? = .setup
    @State private var showingSettings = false
    @ObservedObject private var settings = AppSettings.shared
    @ObservedObject private var appState = AppState.shared // 🆕 Needed to mark app as ready

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                List(AppPage.allCases, selection: $selectedPage) { page in
                    Button {
                        selectedPage = page
                    } label: {
                        HStack {
                            Label(page.rawValue, systemImage: page.icon)
                                .font(.body)
                                .padding(.vertical, 10)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            selectedPage == page ? settings.headerColor.opacity(0.2) : Color.clear
                        )
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(selectedPage == page ? .primary : .secondary)
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
                    .contentShape(Rectangle())
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
            case .comparison:
                MonthlyComparisonPage()
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
        .onAppear {
            initializeApp()
        }
    }

    private func initializeApp() {
        // 👉 If you have real data loading, call it here
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.isAppReady = true // ✅ Tell splash screen we are ready
        }
    }
}
