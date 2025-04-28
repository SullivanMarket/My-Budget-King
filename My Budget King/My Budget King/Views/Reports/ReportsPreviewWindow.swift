//
//  ReportsPreviewWindow.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct ReportsPreviewWindow: View {
    @Binding var isPresented: Bool
    let actuals: [MonthlyActualEntry]
    let selectedType: AppBudgetType
    let selectedYear: Int

    @State private var pdfData: Data? = nil

    var body: some View {
        VStack(spacing: 12) {
            Text("Preview: \(selectedType.rawValue.capitalized) Report \(String(selectedYear))")
                .font(.title2)
                .bold()

            Divider()

            if let pdfData = pdfData {
                PDFKitView(data: pdfData)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white)
                    .cornerRadius(10)
            } else {
                Text("Generating preview...")
                    .padding()
            }

            HStack {
                Spacer()

                Button("Save PDF") {
                    chooseSaveLocation()
                }

                Button("Close") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding()
        .frame(minWidth: 720, minHeight: 540)
        .onAppear {
            generatePDF()
        }
    }

    private func generatePDF() {
        let view = ReportsPrintableView(actuals: actuals, selectedType: selectedType, selectedYear: selectedYear)
        let controller = NSHostingController(rootView: view)
        controller.view.frame = CGRect(x: 0, y: 0, width: 612, height: 792)

        let data = NSMutableData()
        let consumer = CGDataConsumer(data: data as CFMutableData)!
        var mediaBox = CGRect(x: 0, y: 0, width: 612, height: 792)

        guard let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            print("❌ Failed to create PDF context.")
            return
        }

        context.beginPDFPage(nil)
        controller.view.layer?.render(in: context)
        context.endPDFPage()
        context.closePDF()

        pdfData = data as Data
    }

    private func chooseSaveLocation() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [UTType.pdf]
        panel.nameFieldStringValue = "\(selectedType.rawValue.capitalized)-Report-\(selectedYear).pdf"
        panel.canCreateDirectories = true

        if panel.runModal() == .OK, let url = panel.url, let data = pdfData {
            do {
                try data.write(to: url)
                print("✅ PDF saved to \(url.path)")
                isPresented = false
            } catch {
                print("❌ Failed to save PDF: \(error)")
            }
        }
    }
}

struct PDFKitView: NSViewRepresentable {
    let data: Data

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {}
}
