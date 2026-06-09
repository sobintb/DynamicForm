//
//  ToggleInputView.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import SwiftUI

struct ToggleInputView: View {
    let config: ToggleConfig
    let theme: Theme
    @EnvironmentObject var vm: FormViewModel

    private var isOn: Binding<Bool> {
        Binding(
            get: { vm.boolValues[config.id, default: false] },
            set: { vm.boolValues[config.id] = $0
                   if $0 { vm.validationErrors.removeValue(forKey: config.id) } }
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: isOn) {
                HStack(spacing: 2) {
                    Text(config.label)
                        .foregroundStyle(theme.textColor)
                    if config.required { Text("*").foregroundStyle(theme.errorColor) }
                }
            }
            .tint(theme.textColor)
            
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
}
