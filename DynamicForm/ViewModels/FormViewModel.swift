//
//  FormViewModel.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import Foundation
import Combine

@MainActor
final class FormViewModel: ObservableObject {
    
    private let decoder = FormSchemaDecoder()
    
    @Published var schema: FormSchema?
    @Published var textValues:     [String: String]   = [:]
    @Published var boolValues:     [String: Bool]     = [:]
    @Published var multiValues:    [String: Set<String>] = [:]
    @Published var singleValues:   [String: String]   = [:]
    @Published var validationErrors: [String: String] = [:]
    @Published var showConfirmation = false
    @Published var confirmedOutput  = ""
    
    // MARK: - Load JSON
    
    func load() {
        guard let url = Bundle.main.url(forResource: "form", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Could not load form.json")
            return
        }
        do {
            schema = try decoder.decode(FormSchema.self, from: data)
            print("schemaLoadedAtVM == \(String(describing: schema))")
            
            // Getting default values.
            applyDefaults()
        } catch {
            print("Decode error: \(error)")
        }
    }
    
    // MARK: Get Default Values

    private func applyDefaults() {
        guard let fields = schema?.fields else { return }
        for field in fields {
            
            if case .text(let textFieldConfig) = field {
                if let def = textFieldConfig.defaultValue {
                    if let maxCount = textFieldConfig.maxLength {
                        if def.count <= maxCount {
                            textValues[textFieldConfig.id] = def
                        } else {
                            print("Removed default value from text - \(textFieldConfig.id)")
                        }
                    }
                    
                }
            }
            
            if case .dropdown(let config) = field, !config.defaultValues.isEmpty {
                if config.allowMultiple {
                    multiValues[config.id] = Set(config.defaultValues)
                } else {
                    singleValues[config.id] = config.defaultValues.first ?? ""
                }
            }
            
            if case .toggle(let toggleConfig) = field, toggleConfig.defaultValue {
                boolValues[toggleConfig.id] = true
            }
        }
    }

    // MARK: - Sorted fields
    // Sorting fields according to order
    var sortedFields: [FormField] {
        (schema?.fields ?? []).sorted { $0.order < $1.order }
    }

    // MARK: - Validation & Save
    // Live validation
    // Used in textfield to validate
    func updateText(id: String, value: String, subtype: TextSubtype, maxLength: Int?) {
        // 1. Clamp to max length (handles paste correctly)
        let clamped = maxLength.map { String(value.prefix($0)) } ?? value
        
        textValues[id] = clamped
        
        // 2. Live validation
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        
        guard !trimmed.isEmpty else {
            validationErrors.removeValue(forKey: id)
            return
        }
        
        switch subtype {
        case .number:
            let pattern = #"^-?\d+(\.\d+)?$"#
            if trimmed.range(of: pattern, options: .regularExpression) != nil {
                validationErrors.removeValue(forKey: id)
            } else {
                validationErrors[id] = "Enter a valid number."
            }
        case .uri:
            if let url = URL(string: trimmed), url.scheme == "https" || url.scheme == "http" {
                validationErrors.removeValue(forKey: id)
            } else {
                validationErrors[id] = "Enter a valid URL (e.g. https://example.com)."
            }
        default:
            validationErrors.removeValue(forKey: id)
        }
    }
    
    // MARK: - Save Func
    // Used in main view(ContentView) to save.
    func save() {
        //validationErrors = [:]
        guard let fields = schema?.fields else { return }

        for field in fields {
            switch field {
            case .text(let config):
                if config.required {
                    let val = textValues[config.id, default: ""].trimmingCharacters(in: .whitespaces)
                    if val.isEmpty {
                        validationErrors[config.id] = config.errorMessage ?? "\(config.label) is required."
                    }
                }
            case .dropdown(let config):
                if config.required {
                    if config.allowMultiple {
                        if multiValues[config.id, default: []].isEmpty {
                            validationErrors[config.id] = config.errorMessage ?? "\(config.label) is required."
                        }
                    } else {
                        if singleValues[config.id, default: ""].isEmpty {
                            validationErrors[config.id] = config.errorMessage ?? "\(config.label) is required."
                        }
                    }
                    // Removing the error if there is no options.
                    // For ignoring requied dropdown that don't have options(to activate submit button).
                    if config.options.isEmpty {
                        validationErrors.removeValue(forKey: config.id)
                    }
                }
            case .toggle(let config):
                if config.required {
                    if !(boolValues[config.id] ?? false) {
                        validationErrors[config.id] = config.errorMessage ?? "\(config.label) is required."
                    }
                }
            case .checkbox(let config):
                if config.required {
                    if !(boolValues[config.id] ?? false) {
                        validationErrors[config.id] = config.errorMessage ?? "You must accept this to continue."
                    }
                }
            case .unknown:
                break
            }
        }
        
        print("valiErrors== \(validationErrors)")

        if validationErrors.isEmpty {
            let output = buildOutput(fields: fields)
            print("Form Output: \(output)")
            confirmedOutput = output
            showConfirmation = true
        }
    }
    
    // MARK: JSON Output Generator

    private func buildOutput(fields: [FormField]) -> String {
        var dict: [String: Any] = [:]
        for field in fields {
            switch field {
            case .text(let c):
                dict[c.id] = textValues[c.id, default: ""]
            case .dropdown(let c):
                if c.allowMultiple {
                    dict[c.id] = Array(multiValues[c.id, default: []])
                } else {
                    dict[c.id] = singleValues[c.id, default: ""]
                }
            case .toggle(let c):
                dict[c.id] = boolValues[c.id, default: false]
            case .checkbox(let c):
                dict[c.id] = boolValues[c.id, default: false]
            case .unknown:
                break
            }
        }
        if let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
           let str = String(data: data, encoding: .utf8) {
            return str
        }
        return "{}"
    }
    
    
    // MARK: - TextField Focus Management
    // Used in parent view(ContentView)
    @Published var focusedFieldID: String? = nil
    private var focusableFieldIDs: [String] = []

    /// Call this after schema loads, passing only text fields in order
    func registerFocusOrder(from fields: [FormField]) {
        focusableFieldIDs = fields.compactMap {
            if case .text(let config) = $0 { return config.id }
            return nil
        }
    }

    func focusNext() {
        guard let current = focusedFieldID,
              let index = focusableFieldIDs.firstIndex(of: current),
              index + 1 < focusableFieldIDs.count else {
            dismissKeyboard()
            return
        }
        focusedFieldID = focusableFieldIDs[index + 1]
    }

    func dismissKeyboard() {
        focusedFieldID = nil
    }

    var isLastFocusableField: Bool {
        focusedFieldID == focusableFieldIDs.last
    }
}
