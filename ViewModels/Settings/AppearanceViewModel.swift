import SwiftUI
import Combine

@MainActor
final class AppearanceManager: ObservableObject {
	
	static let shared = AppearanceManager()
	
	// MARK: - Published Properties
	
	@Published var selectedTheme: AppTheme {
		didSet {
			saveTheme()
			updateColorScheme()
		}
	}
	
	@Published var selectedAccentColor: AccentColorOption {
		didSet {
			if enableAnimations {
				withAnimation(.easeInOut(duration: 0.3)) {
					saveAccentColor()
				}
			} else {
				saveAccentColor()
			}
		}
	}
	
	@Published var showCharts: Bool {
		didSet {
			UserDefaults.standard.set(showCharts, forKey: "showCharts")
		}
	}
	
	@Published var enableAnimations: Bool {
		didSet {
			UserDefaults.standard.set(enableAnimations, forKey: "enableAnimations")
		}
	}
	
	@Published var useCompactNumbers: Bool {
		didSet {
			UserDefaults.standard.set(useCompactNumbers, forKey: "useCompactNumbers")
		}
	}
	
	@Published var preferredColorScheme: ColorScheme?
	
	// MARK: - Computed Properties
	
	var primaryColor: Color {
		selectedAccentColor.primaryColor
	}
	
	var primaryDarkColor: Color {
		selectedAccentColor.primaryDarkColor
	}
	
	var primarySoftColor: Color {
		selectedAccentColor.primarySoftColor
	}
	
	var accentColor: Color {
		selectedAccentColor.accentColor
	}
	
	// MARK: - Initialization
	
	private init() {
		// Load theme
		if let themeRawValue = UserDefaults.standard.string(forKey: "selectedTheme"),
		   let theme = AppTheme(rawValue: themeRawValue) {
			self.selectedTheme = theme
		} else {
			self.selectedTheme = .system
		}
		
		// Load accent color
		if let colorName = UserDefaults.standard.string(forKey: "selectedAccentColor"),
		   let accentColor = AccentColorOption.allCases.first(where: { $0.name == colorName }) {
			self.selectedAccentColor = accentColor
		} else {
			self.selectedAccentColor = .mint
		}
		
		// Load display options
		self.showCharts = UserDefaults.standard.object(forKey: "showCharts") as? Bool ?? true
		self.enableAnimations = UserDefaults.standard.object(forKey: "enableAnimations") as? Bool ?? true
		self.useCompactNumbers = UserDefaults.standard.object(forKey: "useCompactNumbers") as? Bool ?? false
		
		// Set initial color scheme
		updateColorScheme()
	}
	
	// MARK: - Private Methods
	
	private func saveTheme() {
		UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
	}
	
	private func saveAccentColor() {
		UserDefaults.standard.set(selectedAccentColor.name, forKey: "selectedAccentColor")
	}
	
	private func updateColorScheme() {
		switch selectedTheme {
		case .light:
			preferredColorScheme = .light
		case .dark:
			preferredColorScheme = .dark
		case .system:
			preferredColorScheme = nil
		}
	}
	
	// MARK: - Public Methods
	
	func formattedAmount(_ amount: Double, currencySymbol: String = "$") -> String {
		if useCompactNumbers && abs(amount) >= 1000 {
			let abbreviated = abbreviateNumber(amount)
			return "\(currencySymbol)\(abbreviated)"
		} else {
			return "\(currencySymbol)\(String(format: "%.2f", amount))"
		}
	}
	
	private func abbreviateNumber(_ number: Double) -> String {
		let absNumber = abs(number)
		let sign = number < 0 ? "-" : ""
		
		switch absNumber {
		case 1_000_000...:
			return String(format: "\(sign)%.1fM", absNumber / 1_000_000)
		case 1_000...:
			return String(format: "\(sign)%.1fK", absNumber / 1_000)
		default:
			return String(format: "\(sign)%.2f", absNumber)
		}
	}
}

// MARK: - App Theme

enum AppTheme: String, CaseIterable {
	case light
	case dark
	case system
	
	var displayName: String {
		switch self {
		case .light: return "Light"
		case .dark: return "Dark"
		case .system: return "System"
		}
	}
	
	var icon: String {
		switch self {
		case .light: return "sun.max.fill"
		case .dark: return "moon.fill"
		case .system: return "circle.lefthalf.filled"
		}
	}
}

// MARK: - Accent Color Option

enum AccentColorOption: String, CaseIterable, Hashable {
	case mint
	case blue
	case orange
	case purple
	case pink
	
	var name: String {
		switch self {
		case .mint: return "Mint"
		case .blue: return "Blue"
		case .orange: return "Orange"
		case .purple: return "Purple"
		case .pink: return "Pink"
		}
	}
	
	var primaryColor: Color {
		switch self {
		case .mint: return Color(hex: "#2EC4A5")
		case .blue: return Color(hex: "#007AFF")
		case .orange: return Color(hex: "#FF9500")
		case .purple: return Color(hex: "#AF52DE")
		case .pink: return Color(hex: "#FF2D55")
		}
	}
	
	var primaryDarkColor: Color {
		switch self {
		case .mint: return Color(hex: "#1FA38A")
		case .blue: return Color(hex: "#0051D5")
		case .orange: return Color(hex: "#C77700")
		case .purple: return Color(hex: "#8E3FBF")
		case .pink: return Color(hex: "#D31A42")
		}
	}
	
	var primarySoftColor: Color {
		switch self {
		case .mint: return Color(hex: "#E8F8F3")
		case .blue: return Color(hex: "#E5F1FF")
		case .orange: return Color(hex: "#FFF4E5")
		case .purple: return Color(hex: "#F4ECFF")
		case .pink: return Color(hex: "#FFE5ED")
		}
	}
	
	var accentColor: Color {
		switch self {
		case .mint: return Color(hex: "#7FE3CF")
		case .blue: return Color(hex: "#4DA3FF")
		case .orange: return Color(hex: "#FFB84D")
		case .purple: return Color(hex: "#C97FED")
		case .pink: return Color(hex: "#FF6B8A")
		}
	}
}

