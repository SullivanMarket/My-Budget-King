//
//  Styles.swift
//  My Budget King
//
//  Created by ChatGPT on 4/24/25.
//

import SwiftUI

/// Style for buttons with padding, rounded corners, and hover feedback
struct RoundedActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(configuration.isPressed ? 0.1 : 0.2), radius: 2, x: 0, y: 1)
            )
            .foregroundColor(.primary)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .contentShape(Rectangle()) // ensures the full area is clickable
    }
}

struct SegmentedPickerContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .pickerStyle(SegmentedPickerStyle())
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .frame(width: 220)
    }
}

/// Style for compact warning text (e.g., unsaved changes)
struct WarningTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundColor(.primary)
            .padding(.trailing, 8)
    }
}

/// Style for large title used in section headers
struct SectionHeaderStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.title2.bold())
            .foregroundColor(.primary)
    }
}

/// Style for subtle grey info below headers
struct SubheadlineInfoStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundColor(.gray)
    }
}

// MARK: - Easy Extensions

extension View {
    func warningText() -> some View {
        self.modifier(WarningTextStyle())
    }

    func sectionHeader() -> some View {
        self.modifier(SectionHeaderStyle())
    }

    func subheadlineInfo() -> some View {
        self.modifier(SubheadlineInfoStyle())
    }
}

extension Text {
    func sectionHeaderStyle() -> some View {
        self
            .font(.title2.bold())
            .foregroundColor(.primary)
            .padding(.bottom, 4)
    }
}

extension Text {
    func standardTextStyle() -> some View {
        self
            .font(.body)
            .foregroundColor(.primary)
    }
}
