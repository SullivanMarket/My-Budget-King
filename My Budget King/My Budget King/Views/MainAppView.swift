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
        case .setup: return "pencil.and.list.clipboard"
        case .actuals: return "calendar.badge.clock"
        case .reports: return "chart.bar.xaxis"
        case .comparison: return "chart.bar.doc.horizontal"
        }
    }
}

struct MainAppView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedPage: AppPage? = .setup
    @State private var showingSettings = false
    @ObservedObject private var settings = AppSettings.shared
    @ObservedObject private var appState = AppState.shared

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
                                .foregroundColor(
                                    selectedPage == page
                                    ? .white
                                    : (colorScheme == .light ? .black : .gray)
                                )
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            selectedPage == page ? Color.blue : Color.clear
                        )
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .tag(page)
                }

                Divider()

                Button(action: {
                    showingSettings = true
                }) {
                    Label("Settings", systemImage: "gearshape")
                        .font(.body)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
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
                    .foregroundColor(.white)
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.isAppReady = true
        }
    }
}
