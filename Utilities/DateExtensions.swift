import Foundation

extension Date {

	func startOfDay(in calendar: Calendar = .current) -> Date {
		calendar.startOfDay(for: self)
	}

	func startOfMonth(in calendar: Calendar = .current) -> Date {
		let components = calendar.dateComponents([.year, .month], from: self)
		return calendar.date(from: components) ?? self
	}

	func endOfMonth(in calendar: Calendar = .current) -> Date {
		let start = startOfMonth(in: calendar)
		let next = calendar.date(byAdding: .month, value: 1, to: start) ?? start
		return calendar.date(byAdding: .second, value: -1, to: next) ?? next
	}

	func addingMonths(_ value: Int, in calendar: Calendar = .current) -> Date {
		calendar.date(byAdding: .month, value: value, to: self) ?? self
	}

	func addingDays(_ value: Int, in calendar: Calendar = .current) -> Date {
		calendar.date(byAdding: .day, value: value, to: self) ?? self
	}

	func isSameMonth(as other: Date, in calendar: Calendar = .current) -> Bool {
		let lhs = calendar.dateComponents([.year, .month], from: self)
		let rhs = calendar.dateComponents([.year, .month], from: other)
		return lhs.year == rhs.year && lhs.month == rhs.month
	}

	func formattedShortDay(in locale: Locale = Locale(identifier: AppConstants.currencyLocaleIdentifier)) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "d MMM"
		return formatter.string(from: self)
	}

	func formattedMonthLabel(in locale: Locale = Locale(identifier: AppConstants.currencyLocaleIdentifier)) -> String {
		let formatter = DateFormatter()
		formatter.locale = locale
		formatter.dateFormat = "MMM"
		return formatter.string(from: self)
	}

	func formattedRelative(in locale: Locale = Locale(identifier: AppConstants.currencyLocaleIdentifier)) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.locale = locale
		formatter.unitsStyle = .short
		return formatter.localizedString(for: self, relativeTo: Date())
	}
}
