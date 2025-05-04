//
//  SettingsPopupView.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI

struct SettingsPopupView: View {
    @ObservedObject private var settings = AppSettings.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // 🔵 Header Section
            Text("Settings")
                .font(.title2)
                .bold()
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(settings.headerColor) // header color from settings!

            VStack(spacing: 24) {
                // Appearance Section (Commented out)
                /*
                VStack(alignment: .leading, spacing: 8) {
                    Text("Appearance")
                        .font(.headline)

                    Picker("Appearance", selection: $settings.appearanceRawValue) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 300)
                }
                */

                // Color Pickers Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Colors")
                        .font(.headline)

                    ColorPicker("Header Color", selection: Binding(
                        get: { Color(nsColor: settings.headerColorData.toNSColor()) },
                        set: { newColor in settings.updateHeaderColor(to: NSColor(newColor)) }
                    ))

                    ColorPicker("Section Box Color", selection: Binding(
                        get: { Color(nsColor: settings.sectionBoxColorData.toNSColor()) },
                        set: { newColor in settings.updateSectionBoxColor(to: NSColor(newColor)) }
                    ))

                    ColorPicker("Row Color", selection: Binding(
                        get: { Color(nsColor: settings.fieldRowColorData.toNSColor()) },
                        set: { newColor in settings.updateFieldRowColor(to: NSColor(newColor)) }
                    ))
                }
                .frame(width: 300)

                Spacer()

                // Save/Cancel Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        dismiss()
                    }) {
                        Label("Cancel", systemImage: "xmark")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)

                    Button(action: {
                        dismiss()
                    }) {
                        Label("Save", systemImage: "checkmark")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .frame(width: 400, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(16)
        .shadow(radius: 10)
        .padding()
    }
}

// MARK: - Extension to Convert Color Data
extension Data {
    func toNSColor() -> NSColor {
        if let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: self) {
            return nsColor
        } else {
            return NSColor.white
        }
    }
}
