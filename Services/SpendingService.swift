import Foundation

final class SpendingService: SpendingServiceProtocol {

	private let repository: SpendRepositoryProtocol
	private let calendar: Calendar

	init(repository: SpendRepositoryProtocol, calendar: Calendar = .current) {
		self.repository = repository
		self.calendar = calendar
	}

	func recordSpend(
		userIdentifier: UUID,
		amount: Decimal,
		category: Category,
		summary: String,
		spentAt: Date
	) async throws -> Spend {
		let spend = Spend(
			userIdentifier: userIdentifier,
			amount: amount,
			category: category,
			summary: summary,
			spentAt: spentAt
		)
		try await repository.insert(spend: spend)
		return spend
	}

	func deleteSpend(identifier: UUID) async throws {
		try await repository.delete(identifier: identifier)
	}

	func loadSpends(for userIdentifier: UUID) async throws -> [Spend] {
		try await repository.fetchAll(for: userIdentifier)
	}

	func loadRecentSpends(for userIdentifier: UUID, limit: Int) async throws -> [Spend] {
		try await repository.fetchRecent(for: userIdentifier, limit: limit)
	}

	func summary(for userIdentifier: UUID) async throws -> SpendingSummary {
		let now = Date()
		let thisMonthStart = now.startOfMonth(in: calendar)
		let thisMonthEnd = now.endOfMonth(in: calendar)
		let lastMonthDate = thisMonthStart.addingMonths(-1, in: calendar)
		let lastMonthStart = lastMonthDate.startOfMonth(in: calendar)
		let lastMonthEnd = lastMonthDate.endOfMonth(in: calendar)

		async let thisMonthSpends = repository.fetchInRange(
			userIdentifier: userIdentifier,
			startingAt: thisMonthStart,
			endingAt: thisMonthEnd
		)
		async let lastMonthSpends = repository.fetchInRange(
			userIdentifier: userIdentifier,
			startingAt: lastMonthStart,
			endingAt: lastMonthEnd
		)
		async let totalCount = repository.count(for: userIdentifier)

		let thisMonth = try await thisMonthSpends
		let lastMonth = try await lastMonthSpends
		let count = try await totalCount

		let totalThisMonth = thisMonth.reduce(Decimal(0)) { $0 + $1.amount }
		let totalLastMonth = lastMonth.reduce(Decimal(0)) { $0 + $1.amount }

		let daysElapsed = max(1, calendar.dateComponents([.day], from: thisMonthStart, to: now).day ?? 1)
		let dailyAverage = totalThisMonth / Decimal(daysElapsed)

		let largest = thisMonth.max(by: { $0.amount < $1.amount })

		return SpendingSummary(
			totalThisMonth: totalThisMonth,
			totalLastMonth: totalLastMonth,
			dailyAverageThisMonth: dailyAverage,
			largestSpendThisMonth: largest,
			totalCount: count
		)
	}

	func categoryBreakdownThisMonth(for userIdentifier: UUID) async throws -> [CategoryBreakdown] {
		let now = Date()
		let thisMonthStart = now.startOfMonth(in: calendar)
		let thisMonthEnd = now.endOfMonth(in: calendar)

		let spends = try await repository.fetchInRange(
			userIdentifier: userIdentifier,
			startingAt: thisMonthStart,
			endingAt: thisMonthEnd
		)

		let totalsByCategory = Dictionary(grouping: spends, by: { $0.category })
			.mapValues { items in items.reduce(Decimal(0)) { $0 + $1.amount } }

		let overallTotal = totalsByCategory.values.reduce(Decimal(0), +)

		return totalsByCategory
			.map { entry in
				let proportion: Double
				if overallTotal == 0 {
					proportion = 0
				} else {
					let ratio = entry.value / overallTotal
					proportion = NSDecimalNumber(decimal: ratio).doubleValue
				}
				return CategoryBreakdown(
					category: entry.key,
					total: entry.value,
					proportion: proportion
				)
			}
			.sorted { $0.total > $1.total }
	}

	func monthlyTotals(for userIdentifier: UUID, monthCount: Int) async throws -> [MonthlyTotal] {
		let now = Date()
		let monthStarts: [Date] = (0..<monthCount).reversed().compactMap { offset in
			now.addingMonths(-offset, in: calendar).startOfMonth(in: calendar)
		}

		guard let earliest = monthStarts.first else { return [] }
		let latest = monthStarts.last?.endOfMonth(in: calendar) ?? now

		let spends = try await repository.fetchInRange(
			userIdentifier: userIdentifier,
			startingAt: earliest,
			endingAt: latest
		)

		return monthStarts.map { monthStart in
			let total = spends
				.filter { $0.spentAt.isSameMonth(as: monthStart, in: calendar) }
				.reduce(Decimal(0)) { $0 + $1.amount }

			return MonthlyTotal(
				monthStart: monthStart,
				label: monthStart.formattedMonthLabel(),
				total: total
			)
		}
	}
}
