// Constants.swift
// MintFlow
//

import SwiftUI

enum AppConstants {

    static let appName = "MintFlow"
    static let appTagline = "Your money, flowing smarter."

    enum Colors {
        static let primary        = Color.green
        static let primaryDark    = Color.green.opacity(0.7)  // darker green tint
        static let accent         = Color.blue
        static let background     = Color(.systemGray6)       // light grey background
        static let cardBackground = Color.white
        static let textPrimary    = Color.black
        static let textSecondary  = Color.gray
        static let error          = Color.red
        static let income         = Color.green
        static let expense        = Color.red
    }

    enum Layout {
        static let horizontalPadding: CGFloat = 24
        static let cornerRadius: CGFloat      = 14
        static let cardCornerRadius: CGFloat   = 16
    }
}
