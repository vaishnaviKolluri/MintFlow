// InputField.swift
// MintFlow
//
// Reusable text input with icon

import SwiftUI

struct InputField: View {

    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isEmail: Bool = false
    var keyboardType: UIKeyboardType? = nil

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 24)

            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .textInputAutocapitalization(
                            isEmail || keyboardType != nil ? .never : .words
                        )
                        .keyboardType(
                            keyboardType ?? (isEmail ? .emailAddress : .default)
                        )
                        .autocorrectionDisabled(isEmail || keyboardType != nil)
                }
            }
            .font(.body)
        }
        .padding()
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}
