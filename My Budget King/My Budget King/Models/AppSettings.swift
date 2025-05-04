//
//  AppSettings.swift
//  My Budget King
//
//  Created by Sean Sullivan
//

import SwiftUI

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("appearance") var appearanceRawValue: String = "light" {
        didSet { objectWillChange.send() }
    }

    @AppStorage("headerColor") var headerColorData: Data = AppSettings.defaultColorData(NSColor.systemBlue)
    @AppStorage("sectionBoxColor") var sectionBoxColorData: Data = AppSettings.defaultColorData(NSColor(calibratedRed: 0.9, green: 0.95, blue: 1.0, alpha: 1.0))
    @AppStorage("fieldRowColor") var fieldRowColorData: Data = AppSettings.defaultColorData(NSColor(calibratedWhite: 0.95, alpha: 1.0))

    private init() {}

    var headerColor: Color { color(from: headerColorData) }
    var sectionBoxColor: Color { color(from: sectionBoxColorData) }
    var fieldRowColor: Color { color(from: fieldRowColorData) }

    var colorScheme: ColorScheme? {
        // Always return light mode now
        return .light
    }

    private func color(from data: Data) -> Color {
        if let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
            return Color(nsColor)
        } else {
            return Color.primary
        }
    }

    private static func defaultColorData(_ color: NSColor) -> Data {
        try! NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false)
    }

    func updateHeaderColor(to newColor: NSColor) {
        headerColorData = AppSettings.defaultColorData(newColor)
    }

    func updateSectionBoxColor(to newColor: NSColor) {
        sectionBoxColorData = AppSettings.defaultColorData(newColor)
    }

    func updateFieldRowColor(to newColor: NSColor) {
        fieldRowColorData = AppSettings.defaultColorData(newColor)
    }
}
