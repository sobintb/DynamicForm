//
//  CheckboxInputView.swift
//  DynamicForm
//
//  Created by S O B I N on 04/06/26.
//

import SwiftUI

struct CheckboxInputView: View {
    let config: CheckboxConfig
    let theme: Theme
    @EnvironmentObject var vm: FormViewModel

    private var isChecked: Binding<Bool> {
        Binding(
            get: { vm.boolValues[config.id, default: false] },
            set: { vm.boolValues[config.id] = $0
                   if $0 { vm.validationErrors.removeValue(forKey: config.id) } }
        )
    }

    private var linkColor: Color {
        config.clickableTextColor.flatMap { Color(hex: $0) } ?? .blue
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    isChecked.wrappedValue.toggle()
                } label: {
                    Image(systemName: isChecked.wrappedValue ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(isChecked.wrappedValue ? linkColor : theme.borderColor)
                }
                .buttonStyle(.plain)

                // Render label with tappable links from metadata
                labelWithLinks
                    .font(.subheadline)
                    .foregroundStyle(theme.textColor)
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

    @ViewBuilder
    private var labelWithLinks: some View {
        if let metadata = config.metadata, !metadata.isEmpty {
            // Build AttributedString with clickable links
            let text = buildAttributedLabel(metadata: metadata)
            Text(text)
                .environment(\.openURL, OpenURLAction { url in
                    UIApplication.shared.open(url)
                    return .handled
                })
        } else {
            Text(config.label)
        }
    }

    private func buildAttributedLabel(metadata: [String: String]) -> AttributedString {
        var result = AttributedString(config.label)
        result.foregroundColor = UIColor(theme.textColor)

        for (linkText, urlStr) in metadata {
            guard let range = result.range(of: linkText),
                  let url = URL(string: urlStr) else { continue }
            result[range].link = url
            result[range].foregroundColor = UIColor(linkColor)
        }
        return result
    }
}
