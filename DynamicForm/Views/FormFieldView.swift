//
//  FormFieldView.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import SwiftUI

struct FormFieldView: View {
    let field: FormField
    let theme: Theme
    var focusedID: FocusState<String?>.Binding 
    @EnvironmentObject var vm: FormViewModel

    var body: some View {
        switch field {
        case .text(let config):
            TextInputView(config: config, theme: theme, focusedID: focusedID)
                .environmentObject(vm)
        case .dropdown(let config):
            DropdownInputView(config: config, theme: theme)
                .environmentObject(vm)
        case .toggle(let config):
            ToggleInputView(config: config, theme: theme)
                .environmentObject(vm)
        case .checkbox(let config):
            CheckboxInputView(config: config, theme: theme)
                .environmentObject(vm)
        case .unknown:
            EmptyView() // Defensive: silently skip
        }
    }
}
