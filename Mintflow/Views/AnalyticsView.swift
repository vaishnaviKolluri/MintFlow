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

    private var groupedExpenses: [(category: Category, amount: Decimal)] {

        Dictionary(
            grouping: transactions.filter { $0.type == .expense },
            by: { $0.category }
        )
        .map { category, txns in

            (
                category,
                txns.reduce(0) { $0 + $1.amount }
            )
        }
        .sorted { $0.amount > $1.amount }
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 24) {

                headerSection

                SectionHeader(title: "Monthly Activity")
                chartSection

                financialSummaryChart

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
                    .foregroundColor(AppConstants.Colors.textPrimary)

                Text("Track your financial performance")
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }

            Spacer()

            Image(systemName: "chart.pie.fill")
                .font(.title2)
                .foregroundColor(AppConstants.Colors.primary)
                .padding(12)
                .background(AppConstants.Colors.cardBackground)
                .clipShape(Circle())
                .shadow(
                    color: .black.opacity(0.06),
                    radius: 6,
                    y: 2
                )
        }
    }
}

// MARK: - Main Chart

private extension AnalyticsView {

    var chartSection: some View {

        VStack(alignment: .leading, spacing: 16) {

            if let selectedCategory,
               let selectedAmount {

                Text("\(selectedCategory): $\(selectedAmount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.green)
            }

            Chart {

                ForEach(groupedExpenses, id: \.category.id) { item in

                    let amount = decimalToDouble(item.amount)

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
                    .foregroundStyle(
                        selectedCategory == item.category.displayName
                        ? .green
                        : .green.opacity(0.6)
                    )
                    .cornerRadius(6)
                    .annotation(position: .top) {

                        if selectedCategory == item.category.displayName {

                            Text("$\(amount, specifier: "%.0f")")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .chartOverlay { proxy in

                GeometryReader { geometry in

                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(

                            DragGesture(minimumDistance: 0)
                                .onEnded { value in

                                    let origin = geometry[
                                        proxy.plotAreaFrame
                                    ].origin

                                    let xPosition =
                                        value.location.x - origin.x

                                    if let category: String = proxy.value(
                                        atX: xPosition
                                    ) {

                                        if let match =
                                            groupedExpenses.first(
                                                where: {
                                                    $0.category.displayName
                                                    == category
                                                }
                                            ) {

                                            selectedCategory = category

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
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(
            color: .black.opacity(0.06),
            radius: 6,
            y: 2
        )
    }
}

// MARK: - Financial Summary Chart

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
                .foregroundColor(
                    AppConstants.Colors.textPrimary
                )

            if let selectedSummaryType,
               let selectedSummaryAmount {

                Text(
                    "\(selectedSummaryType): $\(selectedSummaryAmount, specifier: "%.2f")"
                )
                .font(.headline)
                .foregroundColor(.primary)
            }

            Chart {

                ForEach(summaryData, id: \.0) { item in

                    BarMark(
                        x: .value("Type", item.0),
                        y: .value("Amount", item.1)
                    )
                    .foregroundStyle(
                        selectedSummaryType == item.0
                        ? item.2
                        : item.2.opacity(0.6)
                    )
                    .cornerRadius(6)
                    .annotation(position: .top) {

                        if selectedSummaryType == item.0 {

                            Text("$\(item.1, specifier: "%.0f")")
                                .font(.caption.bold())
                        }
                    }
                }
            }
            .chartOverlay { proxy in

                GeometryReader { geometry in

                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(

                            DragGesture(minimumDistance: 0)
                                .onEnded { value in

                                    let origin = geometry[
                                        proxy.plotAreaFrame
                                    ].origin

                                    let xPosition =
                                        value.location.x - origin.x

                                    if let type: String = proxy.value(
                                        atX: xPosition
                                    ) {

                                        if let match =
                                            summaryData.first(
                                                where: {
                                                    $0.0 == type
                                                }
                                            ) {

                                            selectedSummaryType = match.0
                                            selectedSummaryAmount = match.1
                                        }
                                    }
                                }
                        )
                }
            }
            .frame(height: 220)
        }
        .padding()
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(
            color: .black.opacity(0.06),
            radius: 6,
            y: 2
        )
    }
}

// MARK: - Category Breakdown

private extension AnalyticsView {

    var categoryBreakdown: some View {

        VStack(spacing: 0) {

            ForEach(groupedExpenses, id: \.category.id) { item in

                HStack(spacing: 14) {

                    Image(systemName: item.category.icon)
                        .font(.title3)
                        .foregroundColor(
                            AppConstants.Colors.primary
                        )
                        .frame(width: 38, height: 38)
                        .background(
                            AppConstants.Colors.primary
                                .opacity(0.12)
                        )
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 3) {

                        Text(item.category.displayName)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(
                                AppConstants.Colors.textPrimary
                            )

                        Text("Expense Category")
                            .font(.caption)
                            .foregroundColor(
                                AppConstants.Colors.textSecondary
                            )
                    }

                    Spacer()

                    Text(currencyString(item.amount))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(
                            AppConstants.Colors.expense
                        )
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if item.category != groupedExpenses.last?.category {

                    Divider()
                        .padding(.leading, 52)
                }
            }
        }
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(
            AppConstants.Layout.cardCornerRadius
        )
        .shadow(
            color: .black.opacity(0.06),
            radius: 6,
            y: 2
        )
    }
}

// MARK: - Budget Section

private extension AnalyticsView {

    var budgetSection: some View {

        VStack(spacing: 16) {

            ForEach(budgets) { budget in

                let spent =
                    groupedExpenses.first {
                        $0.category == budget.category
                    }?.amount ?? 0

                let progress = min(
                    decimalToDouble(spent / budget.limit),
                    1.0
                )

                VStack(alignment: .leading, spacing: 10) {

                    HStack {

                        Label(
                            budget.category.displayName,
                            systemImage: budget.category.icon
                        )
                        .font(.subheadline.weight(.semibold))

                        Spacer()

                        Text("\(Int(progress * 100))%")
                            .font(.caption.weight(.bold))
                            .foregroundColor(
                                progress > 0.9
                                ? AppConstants.Colors.expense
                                : .green
                            )
                    }

                    ProgressView(value: progress)
                        .tint(
                            progress > 0.9
                            ? AppConstants.Colors.expense
                            : .green
                        )

                    HStack {

                        Text(
                            "Spent: \(currencyString(spent))"
                        )
                        .font(.caption)

                        Spacer()

                        Text(
                            "Limit: \(currencyString(budget.limit))"
                        )
                        .font(.caption)
                    }
                    .foregroundColor(
                        AppConstants.Colors.textSecondary
                    )
                }
                .padding(18)
                .background(
                    AppConstants.Colors.cardBackground
                )
                .cornerRadius(
                    AppConstants.Layout.cardCornerRadius
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 5,
                    y: 2
                )
            }
        }
    }
}

// MARK: - Helpers

private extension AnalyticsView {

    func currencyString(_ amount: Decimal) -> String {

        let number = NSDecimalNumber(decimal: amount)

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency

        return formatter.string(from: number)
            ?? "$0.00"
    }

    func decimalToDouble(_ value: Decimal) -> Double {

        NSDecimalNumber(decimal: value)
            .doubleValue
    }
}
