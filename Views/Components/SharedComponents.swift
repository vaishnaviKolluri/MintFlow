// SharedComponents.swift
// MintFlow
//
// Reusable shared components

import SwiftUI

// Displays a validation or server error 
struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppConstants.Colors.error)
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }
}

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.title3.weight(.semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .padding(12)
                .background(AppConstants.Colors.cardBackground)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        }
        .padding(.leading, AppConstants.Layout.horizontalPadding)
        .padding(.top, 10)
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3.weight(.semibold))
            .foregroundColor(AppConstants.Colors.textPrimary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
