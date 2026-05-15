import SwiftUI
import Combine

struct CurrencySettingsView: View {
	
	@StateObject private var viewModel = CurrencySettingsViewModel()
	@ObservedObject private var currencyManager = CurrencyManager.shared
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		List {
			Section {
				headerSection
			}
			.listRowBackground(Color.clear)
			.listRowInsets(EdgeInsets())
			
			Section("Current Settings") {
				currentCurrencyRow
			}
			
			Section("Popular Currencies") {
				ForEach(viewModel.popularCurrencies) { currency in
					CurrencyRow(
						currency: currency,
						isSelected: viewModel.selectedCurrency.code == currency.code
					) {
						viewModel.selectedCurrency = currency
					}
				}
			}
			
			Section("All Currencies") {
				ForEach(viewModel.filteredCurrencies) { currency in
					CurrencyRow(
						currency: currency,
						isSelected: viewModel.selectedCurrency.code == currency.code
					) {
						viewModel.selectedCurrency = currency
					}
				}
			}
		}
		.listStyle(.insetGrouped)
		.searchable(text: $viewModel.searchText, prompt: "Search currencies")
		.background(AppConstants.Colours.background)
		.navigationTitle("Currency")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.font(.system(size: 16, weight: .semibold))
						.foregroundColor(AppConstants.Colours.textSecondary)
				}
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				if viewModel.hasChanges {
					Button("Save") {
						viewModel.saveCurrency()
						dismiss()
					}
					.fontWeight(.semibold)
				}
			}
		}
	}
	
	// MARK: - Header
	
	private var headerSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Image(systemName: "dollarsign.circle.fill")
					.font(.system(size: 32))
					.foregroundColor(AppConstants.Colours.primary)
				
				Spacer()
			}
			
			Text("Choose your preferred currency")
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.textSecondary)
		}
		.padding(.horizontal, AppConstants.Layout.horizontalPadding)
		.padding(.vertical, 8)
	}
	
	// MARK: - Current Currency
	
	private var currentCurrencyRow: some View {
		VStack(spacing: 12) {
			HStack(spacing: 12) {
				VStack(alignment: .leading, spacing: 2) {
					Text(viewModel.selectedCurrency.name)
						.font(.body.weight(.semibold))
						.foregroundColor(AppConstants.Colours.textPrimary)
					
					Text("Current currency")
						.font(.caption)
						.foregroundColor(AppConstants.Colours.textSecondary)
				}
				
				Spacer()
				
				Text(viewModel.selectedCurrency.symbol)
					.font(.title2.weight(.semibold))
					.foregroundColor(AppConstants.Colours.primary)
			}
			
			// Preview of currency formatting
			Divider()
			
			HStack {
				Text("Preview:")
					.font(.caption)
					.foregroundColor(AppConstants.Colours.textSecondary)
				
				Spacer()
				
				Text(viewModel.formattedPreview)
					.font(.body.weight(.medium))
					.foregroundColor(AppConstants.Colours.textPrimary)
			}
		}
		.padding(.vertical, 4)
	}
}

// MARK: - Currency Row

private struct CurrencyRow: View {
	let currency: Currency
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				Text(currency.name)
					.font(.body)
					.foregroundColor(AppConstants.Colours.textPrimary)
				
				Spacer()
				
				Text(currency.symbol)
					.font(.body.weight(.semibold))
					.foregroundColor(AppConstants.Colours.textSecondary)
				
				if isSelected {
					Image(systemName: "checkmark.circle.fill")
						.foregroundColor(AppConstants.Colours.primary)
						.padding(.leading, 4)
				}
			}
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}
}

// MARK: - View Model

@MainActor
final class CurrencySettingsViewModel: ObservableObject {
	
	@Published var selectedCurrency: Currency
	@Published var searchText: String = ""
	
	private let originalCurrency: Currency
	private let currencyManager = CurrencyManager.shared
	
	var hasChanges: Bool {
		selectedCurrency != originalCurrency
	}
	
	var filteredCurrencies: [Currency] {
		if searchText.isEmpty {
			return allCurrencies
		}
		return allCurrencies.filter { currency in
			currency.name.localizedCaseInsensitiveContains(searchText) ||
			currency.code.localizedCaseInsensitiveContains(searchText) ||
			currency.symbol.localizedCaseInsensitiveContains(searchText)
		}
	}
	
	var formattedPreview: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = selectedCurrency.code
		formatter.currencySymbol = selectedCurrency.symbol
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 2
		
		return formatter.string(from: NSNumber(value: 1234.56)) ?? "\(selectedCurrency.symbol)1,234.56"
	}
	
	init() {
		// Load current currency from manager
		self.selectedCurrency = CurrencyManager.shared.currentCurrency
		self.originalCurrency = CurrencyManager.shared.currentCurrency
	}
	
	func saveCurrency() {
		currencyManager.setCurrency(selectedCurrency)
		print("✅ Currency saved: \(selectedCurrency.name) (\(selectedCurrency.symbol))")
	}
	
	// MARK: - Popular Currencies
	
	let popularCurrencies: [Currency] = [
		Currency(code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸"),
		Currency(code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺"),
		Currency(code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧"),
		Currency(code: "AUD", name: "Australian Dollar", symbol: "$", flag: "🇦🇺"),
		Currency(code: "CAD", name: "Canadian Dollar", symbol: "$", flag: "🇨🇦"),
		Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", flag: "🇯🇵"),
		Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", flag: "🇨🇳"),
	]
	
	// MARK: - All Currencies
	
	let allCurrencies: [Currency] = [
		Currency(code: "AED", name: "UAE Dirham", symbol: "د.إ", flag: "🇦🇪"),
		Currency(code: "AUD", name: "Australian Dollar", symbol: "$", flag: "🇦🇺"),
		Currency(code: "BRL", name: "Brazilian Real", symbol: "R$", flag: "🇧🇷"),
		Currency(code: "CAD", name: "Canadian Dollar", symbol: "$", flag: "🇨🇦"),
		Currency(code: "CHF", name: "Swiss Franc", symbol: "Fr", flag: "🇨🇭"),
		Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", flag: "🇨🇳"),
		Currency(code: "DKK", name: "Danish Krone", symbol: "kr", flag: "🇩🇰"),
		Currency(code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺"),
		Currency(code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧"),
		Currency(code: "HKD", name: "Hong Kong Dollar", symbol: "$", flag: "🇭🇰"),
		Currency(code: "INR", name: "Indian Rupee", symbol: "₹", flag: "🇮🇳"),
		Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", flag: "🇯🇵"),
		Currency(code: "KRW", name: "South Korean Won", symbol: "₩", flag: "🇰🇷"),
		Currency(code: "MXN", name: "Mexican Peso", symbol: "$", flag: "🇲🇽"),
		Currency(code: "NOK", name: "Norwegian Krone", symbol: "kr", flag: "🇳🇴"),
		Currency(code: "NZD", name: "New Zealand Dollar", symbol: "$", flag: "🇳🇿"),
		Currency(code: "PLN", name: "Polish Zloty", symbol: "zł", flag: "🇵🇱"),
		Currency(code: "RUB", name: "Russian Ruble", symbol: "₽", flag: "🇷🇺"),
		Currency(code: "SEK", name: "Swedish Krona", symbol: "kr", flag: "🇸🇪"),
		Currency(code: "SGD", name: "Singapore Dollar", symbol: "$", flag: "🇸🇬"),
		Currency(code: "THB", name: "Thai Baht", symbol: "฿", flag: "🇹🇭"),
		Currency(code: "TRY", name: "Turkish Lira", symbol: "₺", flag: "🇹🇷"),
		Currency(code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸"),
		Currency(code: "ZAR", name: "South African Rand", symbol: "R", flag: "🇿🇦"),
	]
}

#Preview {
	NavigationStack {
		CurrencySettingsView()
	}
}
