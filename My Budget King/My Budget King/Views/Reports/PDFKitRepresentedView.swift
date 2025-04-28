//
//  PDFKitRepresentedView.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/24/25.
//

import SwiftUI
import PDFKit

struct PDFKitRepresentedView: NSViewRepresentable {
    let document: PDFDocument

    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = document
        pdfView.autoScales = true
        return pdfView
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = document
    }
}
