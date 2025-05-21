//
//  ReportsPreviewWindow.swift
//  My Budget King
//
//  Created by Sean Sullivan on 4/23/25.
//

import SwiftUI

struct ReportsPreviewWindow: View {
    let dismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Report Preview Unavailable")
                .font(.title)
                .foregroundColor(.white)

            Text("Please export to PDF to view the final report.")
                .foregroundColor(.white)

            Spacer()

            Button("Close") {
                dismiss()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .frame(width: 500, height: 300)
        .background(Color.blue)
        .cornerRadius(12)
    }
}
