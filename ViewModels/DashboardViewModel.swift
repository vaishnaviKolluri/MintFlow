import Foundation
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {

	@Published private(set) var summary: SpendingSummary?
	@Published private(set) var recentSpends: [Spend] = []
	@Published private(set) var monthlyTotals: [MonthlyTotal] = []
	@Published private(set) var categoryBreakdown: [CategoryBreakdown] = []
	@Published private(set) var isLoading: Bool = false
	@Published private(set) var errorMessage: String?

	let user: User

	private let spendingService: any SpendingServiceProtocol
	private let recentLimit: Int
	private let monthsOfHistory: Int

	init(
		user: User,
		spendingService: any SpendingServiceProtocol = ServiceContainer.shared.spendingService,
		recentLimit: Int = 5,
		monthsOfHistory: Int = 6
	) {
		self.user = user
		self.spendingService = spendingService
		self.recentLimit = recentLimit
		self.monthsOfHistory = monthsOfHistory
	}

	var greetingFirstName: String {
		user.fullName.components(separatedBy: " ").first ?? user.fullName
	}

	var formattedThisMonthTotal: String {
		CurrencyFormatter.format(summary?.totalThisMonth ?? 0)
	}

	var formattedLastMonthTotal: String {
		CurrencyFormatter.format(summary?.totalLastMonth ?? 0)
	}

	var formattedDailyAverage: String {
		CurrencyFormatter.format(summary?.dailyAverageThisMonth ?? 0)
	}

	var monthOverMonthChange: Decimal {
		guard let summary else { return 0 }
		return summary.totalThisMonth - summary.totalLastMonth
	}

	var monthOverMonthDirection: TrendDirection {
		let change = monthOverMonthChange
		if change > 0 { return .up }
		if change < 0 { return .down }
		return .flat
	}

	func load() async {
		isLoading = true
		errorMessage = nil

		do {
			async let summaryFetch = spendingService.summary(for: user.id)
			async let recentFetch = spendingService.loadRecentSpends(for: user.id, limit: recentLimit)
			async let breakdownFetch = spendingService.categoryBreakdownThisMonth(for: user.id)
			async let trendFetch = spendingService.monthlyTotals(for: user.id, monthCount: monthsOfHistory)

			let loadedSummary = try await summaryFetch
			let loadedRecent = try await recentFetch
			let loadedBreakdown = try await breakdownFetch
			let loadedTrend = try await trendFetch

			summary = loadedSummary
			recentSpends = loadedRecent
			categoryBreakdown = loadedBreakdown
			monthlyTotals = loadedTrend
		} catch {
			errorMessage = error.localizedDescription
		}

		isLoading = false
	}

	func refresh() async {
		await load()
	}
}

enum TrendDirection {
	case up
	case down
	case flat

	var iconName: String {
		switch self {
		case .up:	return "arrow.up.right"
		case .down:	return "arrow.down.right"
		case .flat:	return "minus"
		}
	}

	var tintColour: Color {
		switch self {
		case .up:	return AppConstants.Colours.expense
		case .down:	return AppConstants.Colours.primary
		case .flat:	return AppConstants.Colours.textSecondary
		}
	}
}
