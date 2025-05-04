//
//  ExportPDFPopupView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI
import UniformTypeIdentifiers
import PDFKit

struct ExportPDFPopupView: View {
    let actuals: [MonthlyActualFlatEntry]
    let selectedType: AppBudgetType
    let selectedYear: Int
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Preview & Export PDF")
                .font(.title2.bold())

            Divider()

            VStack {
                Text("Preview not available in this window.")
                    .foregroundColor(.secondary)
                    .padding(.top, 100)
                Text("Use the Export button below to save a complete PDF report.")
                    .foregroundColor(.gray)
            }
            .frame(height: 400)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(8)

            HStack {
                Spacer()
                Button("Cancel", role: .cancel) {
                    dismiss()
                }
                Button {
                    chooseSaveLocationAndExport()
                } label: {
                    Label("Save PDF", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(minWidth: 600, minHeight: 500)
    }

    private func chooseSaveLocationAndExport() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.nameFieldStringValue = "\(selectedType.rawValue.capitalized)-Report-\(String(selectedYear)).pdf"
        panel.canCreateDirectories = true

        if panel.runModal() == .OK, let url = panel.url {
            exportToPDF(to: url)
            dismiss()
        }
    }

    private func exportToPDF(to url: URL) {
        print("🖨️ Starting NSPrintOperation PDF export...")

        let view = ReportsPrintableView(
            actuals: actuals.map {
                MonthlyActualFlatEntry(
                    id: $0.id,
                    name: $0.name,
                    categoryName: $0.categoryName,
                    budgetedAmount: $0.budgetedAmount,
                    actualAmount: $0.actualAmount
                )
            },
            selectedType: selectedType,
            selectedYear: selectedYear
        )
        let hostingView = NSHostingView(rootView: view)
        hostingView.frame = NSRect(x: 0, y: 0, width: 612, height: 792) // 8.5" x 11"

        let printInfo = NSPrintInfo()
        printInfo.jobDisposition = NSPrintInfo.JobDisposition.save
        printInfo.horizontalPagination = .automatic
        printInfo.verticalPagination = .automatic
        printInfo.paperSize = NSSize(width: 612, height: 792)
        printInfo.isHorizontallyCentered = false
        printInfo.isVerticallyCentered = false
        printInfo.topMargin = 36
        printInfo.bottomMargin = 36
        printInfo.leftMargin = 36
        printInfo.rightMargin = 36
        printInfo.dictionary()[NSPrintInfo.AttributeKey.jobSavingURL] = url

        let printOperation = NSPrintOperation(view: hostingView, printInfo: printInfo)
        printOperation.showsPrintPanel = false
        printOperation.showsProgressPanel = true

        if printOperation.run() {
            print("✅ PDF successfully saved to \(url.path)")
        } else {
            print("❌ PDF export failed.")
        }
    }
}
