// AnalyticsViewModel.swift
// MintFlow
//
// Aggregates transactions into chart-ready summaries.
// Swift Charts in AnalyticsView consumes these computed values directly.

import Foundation
import Combine

/// Time window the user can switch between on the analytics screen.
enum AnalyticsRange: String, CaseIterable, Identifiable {
    case week
    case month
    case threeMonths
    case year

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .week:        return "Week"
        case .month:       return "Month"
        case .threeMonths: return "3 Months"
        case .year:        return "Year"
        }
    }

    var days: Int {
        switch self {
        case .week:        return 7
        case .month:       return 30
        case .threeMonths: return 90
        case .year:        return 365
        }
    }
}

/// One slice of the category pie chart.
struct CategorySpend: Identifiable, Equatable {
    let id = UUID()
    let category: Category
    let total: Decimal

    var totalDouble: Double { (total as NSDecimalNumber).doubleValue }
}

/// One bar in the monthly trend chart.
struct MonthlyBucket: Identifiable, Equatable {
    let id = UUID()
    let month: Date     // first day of the month
    let income: Decimal
    let expense: Decimal

    var incomeDouble: Double  { (income  as NSDecimalNumber).doubleValue }
    var expenseDouble: Double { (expense as NSDecimalNumber).doubleValue }
}

@MainActor
final class AnalyticsViewModel: ObservableObject {

    // MARK: - Published state

    @Published var range: AnalyticsRange = .month {
        didSet { recompute() }
    }

    @Published private(set) var isLoading = false
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var categoryBreakdown: [CategorySpend] = []
    @Published private(set) var monthlyTrend: [MonthlyBucket] = []
    @Published private(set) var totalIncome: Decimal = 0
    @Published private(set) var totalExpense: Decimal = 0

    // MARK: - Dependencies

    private let user: User
    private let transactionService: any TransactionServiceProtocol

    init(
        user: User,
        transactionService: any TransactionServiceProtocol =
            ServiceContainer.shared.transactionService
    ) {
        self.user = user
        self.transactionService = transactionService
    }

    // MARK: - Derived values

    var netCashFlow: Decimal { totalIncome - totalExpense }

    var topCategory: CategorySpend? {
        categoryBreakdown.first
    }

    var formattedIncome:  String { format(totalIncome) }
    var formattedExpense: String { format(totalExpense) }
    var formattedNet:     String { format(netCashFlow) }

    func formatted(_ value: Decimal) -> String { format(value) }

    // MARK: - Loading

    func load() async {
        isLoading = true
        let all = await transactionService.fetchTransactions(for: user.id)
        self.transactions = all
        recompute()
        isLoading = false
    }

    // MARK: - Aggregation

    private func recompute() {
        let cal = Calendar.current
        let cutoff = cal.date(byAdding: .day, value: -range.days, to: Date()) ?? Date()
        let inRange = transactions.filter { $0.date >= cutoff }

        // Totals
        totalIncome  = inRange.filter { $0.type == .income  }.map(\.amount).reduce(0, +)
        totalExpense = inRange.filter { $0.type == .expense }.map(\.amount).reduce(0, +)

        // Category breakdown (expenses only)
        let grouped = Dictionary(grouping: inRange.filter { $0.type == .expense }) {
            $0.category
        }
        categoryBreakdown = grouped
            .map { CategorySpend(category: $0.key,
                                 total: $0.value.map(\.amount).reduce(0, +)) }
            .sorted { $0.total > $1.total }

        // Monthly trend — always show last 6 months for context
        monthlyTrend = buildMonthlyTrend(from: transactions, months: 6)
    }

    private func buildMonthlyTrend(from txns: [Transaction], months: Int) -> [MonthlyBucket] {
        let cal = Calendar.current
        let now = Date()

        // Build the list of month-starts we want to display
        var monthStarts: [Date] = []
        for i in (0..<months).reversed() {
            if let d = cal.date(byAdding: .month, value: -i, to: now),
               let start = cal.date(from: cal.dateComponents([.year, .month], from: d)) {
                monthStarts.append(start)
            }
        }

        return monthStarts.map { start in
            let end = cal.date(byAdding: .month, value: 1, to: start) ?? start
            let bucket = txns.filter { $0.date >= start && $0.date < end }
            let inc = bucket.filter { $0.type == .income  }.map(\.amount).reduce(0, +)
            let exp = bucket.filter { $0.type == .expense }.map(\.amount).reduce(0, +)
            return MonthlyBucket(month: start, income: inc, expense: exp)
        }
    }

    // MARK: - Formatting

    private func format(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }
}
