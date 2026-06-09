//
//  ContentView.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = FormViewModel()
    @FocusState private var focusedID: String?

    var body: some View {
        NavigationStack {
            Group {
                if let schema = vm.schema {
                    formContent(schema: schema)
                } else {
                    // Fallback if JSON fails to load
                    VStack(alignment: .center) {
                        Image(systemName: "exclamationmark.triangle")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(.gray)
                            
                        Text("Could not load the form configuration.")
                            .font(.headline)
                            .foregroundStyle(.gray)
                    }
                }
            }
            // Load JSON
            .task { vm.load() }
            .navigationTitle(vm.schema?.formTitle ?? "Form")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(vm.schema?.formTitle ?? "Form")
                        .foregroundStyle(vm.schema?.theme.textColor ?? .gray)
                        .font(.headline)
                }
            }
            .alert("Form Submitted!!", isPresented: $vm.showConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(vm.confirmedOutput)
            }
        }
    }

    @ViewBuilder
    private func formContent(schema: FormSchema) -> some View {
        ZStack {
            schema.theme.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    
                    ForEach(vm.sortedFields) { field in
                        FormFieldView(field: field, theme: schema.theme, focusedID: $focusedID)
                            .environmentObject(vm)
                    }

                    Button(action: vm.save) {
                        Text("Save")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(schema.theme.textColor)
                            .foregroundStyle(schema.theme.backgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.top, 12)
                }
                .padding()
            }
        }
        .onAppear {
            vm.registerFocusOrder(from: vm.sortedFields)
        }
        //Two-way sync between @FocusState and VM
        .onChange(of: focusedID) { newValue in
            if vm.focusedFieldID != newValue {
                vm.focusedFieldID = newValue
            }
        }
        .onChange(of: vm.focusedFieldID) { newValue in
            if focusedID != newValue {
                focusedID = newValue
            }
        }
        //Keyboard toolbar lives here, reads from VM
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                if vm.isLastFocusableField {
                    singleButtonToolbar()
                } else {
                    doubleButtonToolbar()
                }
                
            }
        }
    }
    
    // MARK: - Toolbar Buttons
    
    @ViewBuilder
    private func doubleButtonToolbar() -> some View {
        Button("Done") {
            vm.dismissKeyboard()
        }
        
        Spacer()
        
        Button(vm.isLastFocusableField ? "Done" : "Next") {
            vm.focusNext()
        }
        .fontWeight(.semibold)
    }
    
    @ViewBuilder
    private func singleButtonToolbar() -> some View {
        
        Spacer()
        
        Button(vm.isLastFocusableField ? "Done" : "Next") {
            vm.focusNext()
        }
        .fontWeight(.semibold)
    }
}

#Preview {
    ContentView()
}
