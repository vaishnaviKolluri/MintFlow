// PrimaryButton.swift
// MintFlow
//

import SwiftUI

struct PrimaryButton: View {

    let title: String
    let isLoading: Bool
    let action: () -> Void

    init(_ title: String, isLoading: Bool = false, action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(title)
                    .font(.headline)
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [AppConstants.Colors.primary, AppConstants.Colors.primaryDark],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(AppConstants.Layout.cornerRadius)
            .shadow(color: AppConstants.Colors.primary.opacity(0.3), radius: 8, y: 4)
        }
        .disabled(isLoading)
    }
}
