//
//  FieldComponents.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import Foundation

// MARK: - TEXT config
struct TextFieldConfig: Decodable, Identifiable {
    let id: String
    let order: Int
    let subtype: TextSubtype
    let label: String
    let placeholder: String?
    let supportingText: String?
    let maxLength: Int?
    let errorMessage: String?
    let required: Bool
    let defaultValue: String?

    enum CodingKeys: String, CodingKey {
        case id, order, subtype, label, placeholder
        case supportingText = "supporting_text"
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case required
        case defaultValue = "default_value"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        order         = try c.decode(Int.self, forKey: .order)
        subtype       = try c.decode(TextSubtype.self, forKey: .subtype)
        label         = try c.decode(String.self, forKey: .label)
        placeholder   = try c.decodeIfPresent(String.self, forKey: .placeholder)
        supportingText = try c.decodeIfPresent(String.self, forKey: .supportingText)
        maxLength     = try c.decodeIfPresent(Int.self, forKey: .maxLength)
        errorMessage  = try c.decodeIfPresent(String.self, forKey: .errorMessage)
        //errorMessage  = try? c.decodeIfPresent(String.self, forKey: .errorMessage)
        required      = (try? c.decode(Bool.self, forKey: .required)) ?? false
        defaultValue = try c.decodeIfPresent(String.self, forKey: .defaultValue)
    }
}

// MARK: - Field Type Enums (for TEXT)
enum TextSubtype: String, Decodable {
    case plain     = "PLAIN"
    case multiline = "MULTILINE"
    case number    = "NUMBER"
    case uri       = "URI"
    case secure    = "SECURE"
}

// MARK: - DROPDOWN config
struct DropdownConfig: Decodable, Identifiable {
    let id: String
    let order: Int
    let label: String
    let options: [FieldOption]
    let allowMultiple: Bool
    let defaultValues: [String]
    let required: Bool
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case id, order, label, options
        case allowMultiple = "allow_multiple"
        case defaultValues = "default_values"
        case required
        case errorMessage = "error_message"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id            = try c.decode(String.self, forKey: .id)
        order         = try c.decode(Int.self, forKey: .order)
        label         = try c.decode(String.self, forKey: .label)
        options       = (try? c.decode([FieldOption].self, forKey: .options)) ?? []
        allowMultiple = (try? c.decode(Bool.self, forKey: .allowMultiple)) ?? false
        defaultValues = (try? c.decode([String].self, forKey: .defaultValues)) ?? []
        required      = (try? c.decode(Bool.self, forKey: .required)) ?? false
        errorMessage  = try? c.decodeIfPresent(String.self, forKey: .errorMessage)
    }
}

// MARK: - Option (for DROPDOWN)
struct FieldOption: Decodable, Identifiable, Hashable {
    let id: String
    let label: String
}

// MARK: - TOGGLE config
struct ToggleConfig: Decodable, Identifiable {
    let id: String
    let order: Int
    let label: String
    let required: Bool
    let errorMessage: String?
    let defaultValue: Bool

    enum CodingKeys: String, CodingKey {
        case id, order, label, required
        case errorMessage = "error_message"
        case defaultValue = "default_value"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id           = try c.decode(String.self, forKey: .id)
        order        = try c.decode(Int.self, forKey: .order)
        label        = try c.decode(String.self, forKey: .label)
        required     = (try? c.decode(Bool.self, forKey: .required)) ?? false
        errorMessage = try? c.decodeIfPresent(String.self, forKey: .errorMessage)
        defaultValue     = (try? c.decode(Bool.self, forKey: .defaultValue)) ?? false
    }
}

// MARK: - CHECKBOX config
struct CheckboxConfig: Decodable, Identifiable {
    let id: String
    let order: Int
    let label: String
    let required: Bool
    let errorMessage: String?
    let metadata: [String: String]?
    let clickableTextColor: String?

    enum CodingKeys: String, CodingKey {
        case id, order, label, required, metadata
        case errorMessage = "error_message"
        case clickableTextColor = "clickable_text_color"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(String.self, forKey: .id)
        order              = try c.decode(Int.self, forKey: .order)
        label              = try c.decode(String.self, forKey: .label)
        required           = (try? c.decode(Bool.self, forKey: .required)) ?? false
        errorMessage       = try? c.decodeIfPresent(String.self, forKey: .errorMessage)
        metadata           = try? c.decodeIfPresent([String: String].self, forKey: .metadata)
        clickableTextColor = try? c.decodeIfPresent(String.self, forKey: .clickableTextColor)
    }
}
