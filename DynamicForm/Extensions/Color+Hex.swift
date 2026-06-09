//
//  Color+Hex.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import SwiftUI
import OSLog

extension Color {
    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") { cleaned.removeFirst() }

        guard cleaned.count == 6 || cleaned.count == 8 else { return nil }

        var rgb: UInt64 = 0
        guard Scanner(string: cleaned).scanHexInt64(&rgb) else { return nil }

        let r, g, b, a: Double
        if cleaned.count == 8 {
            r = Double((rgb >> 24) & 0xFF) / 255
            g = Double((rgb >> 16) & 0xFF) / 255
            b = Double((rgb >> 8)  & 0xFF) / 255
            a = Double(rgb & 0xFF)          / 255
        } else {
            r = Double((rgb >> 16) & 0xFF) / 255
            g = Double((rgb >> 8)  & 0xFF) / 255
            b = Double(rgb & 0xFF)          / 255
            a = 1.0
        }
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

extension KeyedDecodingContainer {
    func decodeHexColor(
        forKey key: KeyedDecodingContainer.Key,
        fallback: Color = .white,
        logger: Logger = Logger.sdui
    ) -> Color {
        guard let hex = try? decode(String.self, forKey: key) else {
            logger.warning("[Theme] Missing key '\(key.stringValue)' — using fallback")
            return fallback
        }
        guard let color = Color(hex: hex) else {
            logger.warning("[Theme] Invalid hex '\(hex)' for '\(key.stringValue)' — using fallback")
            return fallback
        }
        return color
    }
}

extension Logger {
    static let sdui = Logger(subsystem: "com.yourapp.bundle-id", category: "SDUI")
}
