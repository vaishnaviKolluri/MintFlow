import Foundation
import Combine

@MainActor
final class CurrencyManager: ObservableObject {
	
	static let shared = CurrencyManager()
	
	@Published private(set) var currentCurrency: Currency {
		didSet {
			saveCurrency()
		}
	}
	
	private let userDefaultsKey = "selectedCurrency"
	
	private init() {
		// Load saved currency or use default
		if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
		   let decoded = try? JSONDecoder().decode(Currency.self, from: data) {
			self.currentCurrency = decoded
		} else {
			// Default to AUD
			self.currentCurrency = Currency(
				code: "AUD",
				name: "Australian Dollar",
				symbol: "$",
				flag: "🇦🇺"
			)
		}
	}
	
	func setCurrency(_ currency: Currency) {
		currentCurrency = currency
	}
	
	private func saveCurrency() {
		if let encoded = try? JSONEncoder().encode(currentCurrency) {
			UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
		}
	}
	
	// MARK: - Formatting
	
	func format(_ amount: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = currentCurrency.code
		formatter.currencySymbol = currentCurrency.symbol
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		
		return formatter.string(from: NSNumber(value: amount)) ?? "\(currentCurrency.symbol)\(amount)"
	}
	
	func formatWithoutSymbol(_ amount: Double) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		
		return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
	}
}

