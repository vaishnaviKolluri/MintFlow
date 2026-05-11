// InputField.swift
// MintFlow
//
// Reusable text input with icon

import SwiftUI

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

struct InputField: View {

    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isEmail: Bool = false
    
    #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    var keyboardType: UIKeyboardType? = nil
    #endif

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 24)

            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.body)
            } else {
                TextField(placeholder, text: $text)
                    .font(.body)
                    #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                    .textInputAutocapitalization(
                        isEmail || keyboardType != nil ? .never : .words
                    )
                    .keyboardType(
                        keyboardType ?? (isEmail ? .emailAddress : .default)
                    )
                    .autocorrectionDisabled(isEmail || keyboardType != nil)
                    #endif
            }
        }
        .padding()
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }
}
