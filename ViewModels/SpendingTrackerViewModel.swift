import Foundation
import SwiftUI

enum SpendingFilter: String, CaseIterable, Identifiable {
	case all
	case thisMonth
	case lastMonth

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .all:			return "All time"
		case .thisMonth:	return "This month"
		case .lastMonth:	return "Last month"
		}
	}
}

struct SpendingDaySection: Identifiable, Equatable {
	let dayStart: Date
	let displayLabel: String
	let totalForDay: Decimal
	let spends: [Spend]

	var id: Date { dayStart }
}

@MainActor
final class SpendingTrackerViewModel: ObservableObject {

	@Published private(set) var allSpends: [Spend] = []
	@Published private(set) var sections: [SpendingDaySection] = []
	@Published private(set) var isLoading: Bool = false
	@Published private(set) var errorMessage: String?

	@Published var selectedFilter: SpendingFilter = .all {
		didSet { recomputeSections() }
	}

	@Published var selectedCategory: Category? {
		didSet { recomputeSections() }
	}

	let user: User
	private let spendingService: any SpendingServiceProtocol
	private let calendar: Calendar

	init(
		user: User,
		spendingService: any SpendingServiceProtocol = ServiceContainer.shared.spendingService,
		calendar: Calendar = .current
	) {
		self.user = user
		self.spendingService = spendingService
		self.calendar = calendar
	}

	var formattedFilteredTotal: String {
		let total = filteredSpends().reduce(Decimal(0)) { $0 + $1.amount }
		return CurrencyFormatter.format(total)
	}

	var spendCount: Int {
		filteredSpends().count
	}

	func load() async {
		isLoading = true
		errorMessage = nil

		do {
			allSpends = try await spendingService.loadSpends(for: user.id)
			recomputeSections()
		} catch {
			errorMessage = error.localizedDescription
		}

		isLoading = false
	}

	func refresh() async {
		await load()
	}

	func deleteSpend(_ spend: Spend) async {
		do {
			try await spendingService.deleteSpend(identifier: spend.identifier)
			allSpends.removeAll { $0.identifier == spend.identifier }
			recomputeSections()
		} catch {
			errorMessage = error.localizedDescription
		}
	}

	func clearCategoryFilter() {
		selectedCategory = nil
	}

	private func filteredSpends() -> [Spend] {
		let dateFiltered: [Spend]
		let now = Date()

		switch selectedFilter {
		case .all:
			dateFiltered = allSpends
		case .thisMonth:
			let start = now.startOfMonth(in: calendar)
			let end = now.endOfMonth(in: calendar)
			dateFiltered = allSpends.filter { $0.spentAt >= start && $0.spentAt <= end }
		case .lastMonth:
			let lastMonth = now.addingMonths(-1, in: calendar)
			let start = lastMonth.startOfMonth(in: calendar)
			let end = lastMonth.endOfMonth(in: calendar)
			dateFiltered = allSpends.filter { $0.spentAt >= start && $0.spentAt <= end }
		}

		guard let category = selectedCategory else {
			return dateFiltered
		}
		return dateFiltered.filter { $0.category == category }
	}

	private func recomputeSections() {
		let working = filteredSpends()
		let grouped = Dictionary(grouping: working) { spend in
			spend.spentAt.startOfDay(in: calendar)
		}

		sections = grouped.keys
			.sorted(by: >)
			.map { dayStart in
				let items = grouped[dayStart] ?? []
				let dayTotal = items.reduce(Decimal(0)) { $0 + $1.amount }
				return SpendingDaySection(
					dayStart: dayStart,
					displayLabel: Self.dayLabel(for: dayStart, calendar: calendar),
					totalForDay: dayTotal,
					spends: items.sorted(by: { $0.spentAt > $1.spentAt })
				)
			}
	}

	private static func dayLabel(for date: Date, calendar: Calendar) -> String {
		if calendar.isDateInToday(date) { return "Today" }
		if calendar.isDateInYesterday(date) { return "Yesterday" }
		return date.formattedShortDay()
	}
}
