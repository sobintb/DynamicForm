//
//  TextInputView.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import SwiftUI

struct TextInputView: View {
    let config: TextFieldConfig
    let theme: Theme
    var focusedID: FocusState<String?>.Binding   // ← added
    @EnvironmentObject var vm: FormViewModel

    private var text: Binding<String> {
        Binding(
            get: { vm.textValues[config.id, default: ""] },
            set: { newVal in
                vm.updateText(id: config.id, value: newVal, subtype: config.subtype, maxLength: config.maxLength)
            }
        )
    }

    // For error color
    private var hasError: Bool {
        vm.validationErrors[config.id] != nil
    }
    
    // For active border color
    private var isFocused: Bool {
        focusedID.wrappedValue == config.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(config.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.textColor)
                if config.required {
                    Text("*").foregroundStyle(theme.errorColor)
                }
            }

            inputField
                .padding(12)
                .focused(focusedID, equals: config.id)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            hasError ? theme.errorColor :
                            isFocused ? Color.blue :
                            theme.borderColor,
                            lineWidth: hasError || isFocused ? 2 : 1.5
                        )
                )
            
            // Reserving error space always.
            HStack {
                if let max = config.maxLength {
                    if let error = vm.validationErrors[config.id] {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(theme.errorColor)
                            .transition(.opacity)
                    }
                    Spacer()
                    Text("\(text.wrappedValue.count)/\(max)")
                        .font(.caption)
                        .foregroundColor(text.wrappedValue.count >= max ? theme.errorColor : theme.textColor.opacity(0.5))
                    
                } else if let error = vm.validationErrors[config.id] {
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

    @ViewBuilder
    private var inputField: some View {
        let placeholder = config.placeholder ?? ""
        switch config.subtype {
        case .plain:
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundColor(theme.textColor.opacity(0.5))
            )
                .foregroundStyle(theme.textColor)
        case .multiline:
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundColor(theme.textColor),
                axis: .vertical
            )
                .lineLimit(3...6)
                .foregroundStyle(theme.textColor)
        case .number:
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundColor(theme.textColor.opacity(0.5))
            )
                .keyboardType(.decimalPad)
                .foregroundStyle(theme.textColor)
        case .uri:
            TextField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundColor(theme.textColor.opacity(0.5))
            )
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .foregroundStyle(theme.textColor)
        case .secure:
            SecureField(
                "",
                text: text,
                prompt: Text(placeholder)
                    .foregroundColor(theme.textColor.opacity(0.5))
            )
                .foregroundStyle(theme.textColor)
        }
    }
}
