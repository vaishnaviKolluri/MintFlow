import Foundation

enum CurrencyFormatter {

    static func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = AppConstants.currencyCode
        formatter.locale = Locale(identifier: AppConstants.currencyLocaleIdentifier)
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: value as NSDecimalNumber) ?? "$0.00"
    }

    static func format(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = AppConstants.currencyCode
        formatter.locale = Locale(identifier: AppConstants.currencyLocaleIdentifier)
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
