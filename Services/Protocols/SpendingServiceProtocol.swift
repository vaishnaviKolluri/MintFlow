import Foundation

struct SpendingSummary: Equatable, Sendable {

	let totalThisMonth: Decimal
	let totalLastMonth: Decimal
	let dailyAverageThisMonth: Decimal
	let largestSpendThisMonth: Spend?
	let totalCount: Int
}

struct CategoryBreakdown: Identifiable, Equatable, Sendable {

	let category: Category
	let total: Decimal
	let proportion: Double

	var id: String { category.rawValue }
}

struct MonthlyTotal: Identifiable, Equatable, Sendable {

	let monthStart: Date
	let label: String
	let total: Decimal

	var id: Date { monthStart }
}

protocol SpendingServiceProtocol: Sendable {

	func recordSpend(
		userIdentifier: UUID,
		amount: Decimal,
		category: Category,
		summary: String,
		spentAt: Date
	) async throws -> Spend

	func deleteSpend(identifier: UUID) async throws

	func loadSpends(for userIdentifier: UUID) async throws -> [Spend]
	func loadRecentSpends(for userIdentifier: UUID, limit: Int) async throws -> [Spend]

	func summary(for userIdentifier: UUID) async throws -> SpendingSummary
	func categoryBreakdownThisMonth(for userIdentifier: UUID) async throws -> [CategoryBreakdown]
	func monthlyTotals(for userIdentifier: UUID, monthCount: Int) async throws -> [MonthlyTotal]
}
