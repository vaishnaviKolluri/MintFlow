import SwiftUI

enum AppConstants {

    static let appName = "MintFlow"
    static let appTagline = "Your money, flowing smarter."
    static let currencyCode = "AUD"
    static let currencyLocaleIdentifier = "en_AU"

    enum Colours {
        static let primary            = Color(hex: "#2EC4A5")
        static let primaryDark        = Color(hex: "#1FA38A")
        static let primarySoft        = Color(hex: "#E8F8F3")
        static let accent            = Color(hex: "#7FE3CF")
        static let background        = Color(hex: "#FAFCFB")
        static let cardBackground    = Color.white
        static let textPrimary        = Color(hex: "#0F1F1B")
        static let textSecondary    = Color(hex: "#6B7B77")
        static let divider            = Color(hex: "#ECF1EE")
        static let error            = Color(hex: "#E07A5F")
        static let income            = Color(hex: "#2EC4A5")
        static let expense            = Color(hex: "#E07A5F")
    }

    enum Colors {
        static let primary            = Colours.primary
        static let primaryDark        = Colours.primaryDark
        static let accent            = Colours.accent
        static let background        = Colours.background
        static let cardBackground    = Colours.cardBackground
        static let textPrimary        = Colours.textPrimary
        static let textSecondary    = Colours.textSecondary
        static let error            = Colours.error
        static let income            = Colours.income
        static let expense            = Colours.expense
    }

    enum Layout {
        static let horizontalPadding: CGFloat    = 24
        static let cornerRadius: CGFloat        = 14
        static let cardCornerRadius: CGFloat    = 18
        static let tileSpacing: CGFloat            = 12
    }
}
