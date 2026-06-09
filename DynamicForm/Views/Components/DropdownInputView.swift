//
//  DropdownInputView.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import SwiftUI

struct DropdownInputView: View {
    let config: DropdownConfig
    let theme: Theme
    @EnvironmentObject var vm: FormViewModel

    private var selectedIds: Binding<Set<String>> {
        Binding(
            get: { vm.multiValues[config.id, default: Set(config.defaultValues)] },
            set: { vm.multiValues[config.id] = $0
                   vm.validationErrors.removeValue(forKey: config.id) }
        )
    }

    private var selectedSingle: Binding<String> {
        Binding(
            get: { vm.singleValues[config.id, default: config.defaultValues.first ?? ""] },
            set: { vm.singleValues[config.id] = $0
                   vm.validationErrors.removeValue(forKey: config.id) }
        )
    }

    private var hasError: Bool { vm.validationErrors[config.id] != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(config.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.textColor)
                if config.required { Text("*").foregroundStyle(theme.errorColor) }
            }

            if config.allowMultiple {
                multiSelectMenu
            } else {
                singleSelectPicker
            }
            
            // Reserving error space always.
            HStack {
                if let error = vm.validationErrors[config.id] {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(theme.errorColor)
                        .transition(.opacity)
                } else {
                    Text(" ")
                        .font(.caption)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.validationErrors[config.id])
    }

    // MARK: Multi-select
    private var multiSelectMenu: some View {
        Menu {
            ForEach(config.options) { option in
                Button {
                    var current = selectedIds.wrappedValue
                    if current.contains(option.id) {
                        current.remove(option.id)
                    } else {
                        current.insert(option.id)
                    }
                    selectedIds.wrappedValue = current
                } label: {
                    HStack {
                        Text(option.label)
                        if selectedIds.wrappedValue.contains(option.id) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(multiSelectionLabel)
                    .foregroundStyle(theme.textColor)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasError ? theme.errorColor : theme.borderColor, lineWidth: 1.5)
            )
        }
    }

    private var multiSelectionLabel: String {
        let ids = selectedIds.wrappedValue
        if ids.isEmpty { return "Select…" }
        return config.options
            .filter { ids.contains($0.id) }
            .map(\.label)
            .joined(separator: ", ")
    }

    // MARK: Single-select
    private var singleSelectPicker: some View {
        Menu {
            ForEach(config.options) { option in
                Button(option.label) {
                    selectedSingle.wrappedValue = option.id
                }
            }
        } label: {
            HStack {
                Text(singleSelectionLabel)
                    .foregroundStyle(theme.textColor)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasError ? theme.errorColor : theme.borderColor, lineWidth: 1.5)
            )
        }
    }

    private var singleSelectionLabel: String {
        let id = selectedSingle.wrappedValue
        return config.options.first(where: { $0.id == id })?.label ?? "Select…"
    }
}
