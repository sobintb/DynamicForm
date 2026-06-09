//
//  FormSchema.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import Foundation
import SwiftUI

// MARK: - Root Schema
struct FormSchema: Decodable {
    let theme: Theme
    let formTitle: String
    let fields: [FormField]

    enum CodingKeys: String, CodingKey {
        case theme
        case formTitle = "form_title"
        case fields
    }
}

// MARK: - Theme
struct Theme: Decodable {
    let backgroundColor: Color
    let textColor: Color
    let borderColor: Color
    let errorColor: Color

    enum CodingKeys: String, CodingKey {
        case backgroundColor = "background_color"
        case textColor = "text_color"
        case borderColor = "border_color"
        case errorColor = "error_color"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        backgroundColor = c.decodeHexColor(forKey: .backgroundColor, fallback: .white)
        textColor       = c.decodeHexColor(forKey: .textColor, fallback: .black)
        borderColor     = c.decodeHexColor(forKey: .borderColor, fallback: .gray)
        errorColor      = c.decodeHexColor(forKey: .errorColor, fallback: .red)
    }
}

// MARK: - Polymorphic FormField
enum FormField: Identifiable {
    case text(TextFieldConfig)
    case dropdown(DropdownConfig)
    case toggle(ToggleConfig)
    case checkbox(CheckboxConfig)
    case unknown(id: String, order: Int)

    var id: String {
        switch self {
        case .text(let c):     return c.id
        case .dropdown(let c): return c.id
        case .toggle(let c):   return c.id
        case .checkbox(let c): return c.id
        case .unknown(let id, _): return id
        }
    }

    var order: Int {
        switch self {
        case .text(let c):     return c.order
        case .dropdown(let c): return c.order
        case .toggle(let c):   return c.order
        case .checkbox(let c): return c.order
        case .unknown(_, let o): return o
        }
    }
}

extension FormField: Decodable {
    enum TypeKey: String, Decodable {
        case text     = "TEXT"
        case dropdown = "DROPDOWN"
        case toggle   = "TOGGLE"
        case checkbox = "CHECKBOX"
    }

    private enum CodingKeys: String, CodingKey {
        case id, type, order
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id    = try container.decode(String.self, forKey: .id)
        print("idChk== \(id)")
        let order = try container.decode(Int.self, forKey: .order)
        let typeRaw = try container.decode(String.self, forKey: .type)

        switch TypeKey(rawValue: typeRaw) {
        case .text:
            self = .text(try TextFieldConfig(from: decoder))
        case .dropdown:
            self = .dropdown(try DropdownConfig(from: decoder))
        case .toggle:
            self = .toggle(try ToggleConfig(from: decoder))
        case .checkbox:
            self = .checkbox(try CheckboxConfig(from: decoder))
        case .none:
            // Defensive: unknown type — don't crash
            self = .unknown(id: id, order: order)
        }
    }
}
