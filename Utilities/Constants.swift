// AppConstants.swift
// MintFlow
//
// App-wide constants for colors, layout, and branding

import SwiftUI

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

enum AppConstants {
    
    // MARK: - App Info
    
    static let appName = "MintFlow"
    static let appTagline = "Your personal finance companion"
    
    // MARK: - Colors
    
    enum Colors {
        static let primary = Color(red: 0.2, green: 0.7, blue: 0.5)
        static let primaryDark = Color(red: 0.1, green: 0.5, blue: 0.4)
        static let accent = Color(red: 1.0, green: 0.6, blue: 0.0)
        
        #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
        static let background = Color(UIColor.systemBackground)
        static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        static let cardBackground = Color(UIColor.secondarySystemBackground)
        static let textPrimary = Color(UIColor.label)
        static let textSecondary = Color(UIColor.secondaryLabel)
        #elseif os(macOS)
        static let background = Color(NSColor.windowBackgroundColor)
        static let secondaryBackground = Color(NSColor.controlBackgroundColor)
        static let cardBackground = Color(NSColor.controlBackgroundColor)
        static let textPrimary = Color(NSColor.labelColor)
        static let textSecondary = Color(NSColor.secondaryLabelColor)
        #else
        static let background = Color.white
        static let secondaryBackground = Color.gray.opacity(0.1)
        static let cardBackground = Color.gray.opacity(0.1)
        static let textPrimary = Color.black
        static let textSecondary = Color.gray
        #endif
        
        static let income = Color.green
        static let expense = Color.red
        static let error = Color.red
        static let success = Color.green
    }
    
    // MARK: - Layout
    
    enum Layout {
        static let horizontalPadding: CGFloat = 24
        static let verticalSpacing: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let cardCornerRadius: CGFloat = 12
        static let cardPadding: CGFloat = 16
    }
}
