//
// AnalyticsView.swift
// MintFlow
//

import SwiftUI
import Charts

struct AnalyticsView: View {

    let transactions: [Transaction]
    let budgets: [Budget]

    @State private var selectedCategory: String?
    @State private var selectedAmount: Double?

    @State private var selectedSummaryType: String?
    @State private var selectedSummaryAmount: Double?

    // MARK: - Computed Values

    private var totalIncome: Decimal {
        transactions
            .filter { $0.type == .income }
            .reduce(0) { $0 + $1.amount }
    }

    private var totalExpenses: Decimal {
        transactions
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    private var savings: Decimal {
        totalIncome - totalExpenses
    }

    private var averageExpense: Decimal {

        let expenses = transactions.filter {
            $0.type == .expense
        }

        guard !expenses.isEmpty else { return 0 }

        let total = expenses.reduce(0) {
            $0 + $1.amount
        }

        return total / Decimal(expenses.count)
    }

    private var highestExpense: Transaction? {

        transactions
            .filter { $0.type == .expense }
            .max {
                $0.amount < $1.amount
            }
    }

    private var groupedExpenses: [(category: Category, amount: Decimal)] {

        Dictionary(
            grouping: transactions.filter {
                $0.type == .expense
            },
            by: { $0.category }
        )
        .map { category, txns in

            (
                category,
                txns.reduce(0) {
                    $0 + $1.amount
                }
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    private var weeklyData: [(String, Double)] {

        [
            ("Mon", 120),
            ("Tue", 80),
            ("Wed", 220),
            ("Thu", 60),
            ("Fri", 310),
            ("Sat", 190),
            ("Sun", 140)
        ]
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                headerSection

                analyticsCards

                SectionHeader(title: "Category Spending")
                chartSection

                financialSummaryChart

                weeklySpendingChart

                SectionHeader(title: "Insights")
                insightsSection

                SectionHeader(title: "Spending Breakdown")
                categoryBreakdown

                Spacer(minLength: 40)
            }
            .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            .padding(.top, 16)
        }
        .background(
            AppConstants.Colors.background
                .ignoresSafeArea()
        )
    }
}

// MARK: - Header

private extension AnalyticsView {

    var headerSection: some View {

        HStack {

            VStack(alignment: .leading, spacing: 4) {

                Text("Analytics")
                    .font(.title.weight(.bold))
                    .foregroundColor(
                        AppConstants.Colors.textPrimary
                    )

                Text("Track your financial performance")
                    .font(.subheadline)
                    .foregroundColor(
                        AppConstants.Colors.textSecondary
                    )
            }

            Spacer()

            Image(systemName: "chart.xyaxis.line")
                .font(.title2)
                .foregroundColor(.green)
                .padding(12)
                .background(
                    AppConstants.Colors.cardBackground
                )
                .clipShape(Circle())
        }
    }
}

// MARK: - Analytics Cards

private extension AnalyticsView {

    var analyticsCards: some View {

        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 16
        ) {

            analyticsCard(
                title: "Income",
                value: currencyString(totalIncome),
                icon: "arrow.down.circle.fill",
                color: .green
            )

            analyticsCard(
                title: "Expenses",
                value: currencyString(totalExpenses),
                icon: "arrow.up.circle.fill",
                color: .red
            )

            analyticsCard(
                title: "Savings",
                value: currencyString(savings),
                icon: "banknote.fill",
                color: .blue
            )

            analyticsCard(
                title: "Avg Expense",
                value: currencyString(averageExpense),
                icon: "chart.bar.fill",
                color: .orange
            )
        }
    }

    func analyticsCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {

        VStack(alignment: .leading, spacing: 12) {

            HStack {

                Image(systemName: icon)
                    .foregroundColor(color)

                Spacer()
            }

            Text(value)
                .font(.title3.bold())

            Text(title)
                .font(.caption)
                .foregroundColor(
                    AppConstants.Colors.textSecondary
                )
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            AppConstants.Colors.cardBackground
        )
        .cornerRadius(
            AppConstants.Layout.cardCornerRadius
        )
    }
}

// MARK: - Category Chart

private extension AnalyticsView {

    var chartSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            if let selectedCategory,
               let selectedAmount {

                Text(
                    "\(selectedCategory): $\(selectedAmount, specifier: "%.2f")"
                )
                .font(.headline)
                .foregroundColor(.green)
            }

            Chart {

                ForEach(
                    groupedExpenses,
                    id: \.category.id
                ) { item in

                    let amount =
                        decimalToDouble(item.amount)

                    BarMark(
                        x: .value(
                            "Category",
                            item.category.displayName
                        ),
                        y: .value(
                            "Amount",
                            amount
                        )
                    )
                    .foregroundStyle(.green)
                    .cornerRadius(6)
                }
            }
            .chartOverlay { proxy in

                GeometryReader { geometry in

                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(
                                minimumDistance: 0
                            )
                            .onEnded { value in

                                let origin =
                                    geometry[
                                        proxy.plotAreaFrame
                                    ].origin

                                let xPosition =
                                    value.location.x
                                    - origin.x

                                if let category: String =
                                    proxy.value(
                                        atX: xPosition
                                    ) {

                                    if let match =
                                        groupedExpenses.first(
                                            where: {
                                                $0.category.displayName
                                                == category
                                            }
                                        ) {

                                        selectedCategory =
                                            category

                                        selectedAmount =
                                            decimalToDouble(
                                                match.amount
                                            )
                                    }
                                }
                            }
                        )
                }
            }
            .frame(height: 240)
        }
        .padding()
        .background(
            AppConstants.Colors.cardBackground
        )
        .cornerRadius(
            AppConstants.Layout.cardCornerRadius
        )
    }
}

// MARK: - Summary Chart

private extension AnalyticsView {

    var financialSummaryChart: some View {

        let summaryData: [(String, Double, Color)] = [

            (
                "Money In",
                decimalToDouble(totalIncome),
                .green
            ),

            (
                "Money Out",
                decimalToDouble(totalExpenses),
                .red
            ),

            (
                "Leftover",
                decimalToDouble(savings),
                .blue
            )
        ]

        return VStack(alignment: .leading, spacing: 16) {

            Text("Financial Summary")
                .font(.headline)

            if let selectedSummaryType,
               let selectedSummaryAmount {

                Text(
                    "\(selectedSummaryType): $\(selectedSummaryAmount, specifier: "%.2f")"
                )
                .font(.headline)
            }

            Chart {

                ForEach(summaryData, id: \.0) {
                    item in

                    BarMark(
                        x: .value(
                            "Type",
                            item.0
                        ),
                        y: .value(
                            "Amount",
                            item.1
                        )
                    )
                    .foregroundStyle(item.2)
                    .cornerRadius(6)
                }
            }
            .chartOverlay { proxy in

                GeometryReader { geometry in

                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(
                                minimumDistance: 0
                            )
                            .onEnded { value in

                                let origin =
                                    geometry[
                                        proxy.plotAreaFrame
                                    ].origin

                                let xPosition =
                                    value.location.x
                                    - origin.x

                                if let type: String =
                                    proxy.value(
                                        atX: xPosition
                                    ) {

                                    if let match =
                                        summaryData.first(
                                            where: {
                                                $0.0 == type
                                            }
                                        ) {

                                        selectedSummaryType =
                                            match.0

                                        selectedSummaryAmount =
                                            match.1
                                    }
                                }
                            }
                        )
                }
            }
            .frame(height: 220)
        }
        .padding()
        .background(
            AppConstants.Colors.cardBackground
        )
        .cornerRadius(
            AppConstants.Layout.cardCornerRadius
        )
    }
}

// MARK: - Weekly Chart

private extension AnalyticsView {

    var weeklySpendingChart: some View {

        VStack(alignment: .leading, spacing: 16) {

            Text("Weekly Spending Trend")
                .font(.headline)

            Chart {

                ForEach(weeklyData, id: \.0) {
                    item in

                    LineMark(
                        x: .value("Day", item.0),
                        y: .value(
                            "Amount",
                            item.1
                        )
                    )
                    .foregroundStyle(.purple)

                    AreaMark(
                        x: .value("Day", item.0),
                        y: .value(
                            "Amount",
                            item.1
                        )
                    )
                    .foregroundStyle(
                        .purple.opacity(0.2)
                    )
                }
            }
            .frame(height: 220)
        }
        .padding()
        .background(
            AppConstants.Colors.cardBackground
        )
        .cornerRadius(
            AppConstants.Layout.cardCornerRadius
        )
    }
}

// MARK: - Insights

private extension AnalyticsView {

    var insightsSection: some View {

        VStack(spacing: 16) {

            insightCard(
                title: "Top Spending Category",
                value: groupedExpenses.first?
                    .category.displayName ?? "None",
                icon: "crown.fill",
                color: .orange
            )

            insightCard(
                title: "Largest Expense",
                value: highestExpense != nil
                    ? currencyString(
                        highestExpense!.amount
                    )
                    : "$0",
                icon: "exclamationmark.triangle.fill",
                color: .red
            )

            insightCard(
                title: "Savings Rate",
                value:
                    "\(Int((decimalToDouble(savings) / max(decimalToDouble(totalIncome), 1)) * 100))%",
                icon: "percent",
                color: .green
            )
        }
    }

    func insightCard(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) -> some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 46, height: 46)
                .background(color)
                .clipShape(Circle())

            VStack(
                alignment: .leading,
                spacing: 4
            ) {

                Text(title)
                    .font(.caption)
                    .foregroundColor(
                        AppConstants.Colors.textSecondary
                    )

                Text(value)
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(
            AppConstants.Colors.cardBackground
        )
        .cornerRadius(
            AppConstants.Layout.cardCornerRadius
        )
    }
}

// MARK: - Category Breakdown

private extension AnalyticsView {

    var categoryBreakdown: some View {

        VStack(spacing: 0) {

            ForEach(
                groupedExpenses,
                id: \.category.id
            ) { item in

                HStack(spacing: 14) {

                    Image(
                        systemName:
                            item.category.icon
                    )
                    .font(.title3)
                    .foregroundColor(.green)
                    .frame(width: 38, height: 38)
                    .background(
                        .green.opacity(0.12)
                    )
                    .clipShape(Circle())

                    VStack(
                        alignment: .leading,
                        spacing: 3
                    ) {

                        Text(
                            item.category.displayName
                        )
                        .font(
                            .subheadline.weight(
                                .medium
                            )
                        )

                        Text("Expense Category")
                            .font(.caption)
                            .foregroundColor(
                                AppConstants
                                    .Colors
                                    .textSecondary
                            )
                    }

                    Spacer()

                    Text(
                        currencyString(
                            item.amount
                        )
                    )
                    .font(
                        .subheadline.weight(
                            .semibold
                        )
                    )
                    .foregroundColor(.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if item.category
                    != groupedExpenses.last?
                    .category {

                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .background(
            AppConstants.Colors.cardBackground
        )
        .cornerRadius(
            AppConstants.Layout.cardCornerRadius
        )
    }
}

// MARK: - Helpers

private extension AnalyticsView {

    func currencyString(
        _ amount: Decimal
    ) -> String {

        let number =
            NSDecimalNumber(decimal: amount)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        return formatter.string(from: number)
            ?? "$0.00"
    }

    func decimalToDouble(
        _ value: Decimal
    ) -> Double {

        NSDecimalNumber(decimal: value)
            .doubleValue
    }
}
