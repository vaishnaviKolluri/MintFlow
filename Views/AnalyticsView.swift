// AnalyticsView.swift
// MintFlow
//
// Spending analytics dashboard. Uses Swift Charts (iOS 16+).

import SwiftUI
import Charts

struct AnalyticsView: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel: AnalyticsViewModel

    init(user: User) {
        _viewModel = StateObject(wrappedValue: AnalyticsViewModel(user: user))
    }

    var body: some View {
        ZStack {
            AppConstants.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    headerTitle

                    rangePicker

                    summaryCards

                    SectionHeader(title: "Spending by Category")
                    categoryChartCard

                    SectionHeader(title: "Income vs. Expense (Last 6 Months)")
                    monthlyTrendCard

                    SectionHeader(title: "Top Categories")
                    categoryListCard

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                .padding(.top, 16)
            }
        }
        .overlay(alignment: .topLeading) {
            BackButton { appViewModel.navigate(to: .home) }
        }
        .task { await viewModel.load() }
    }

    // MARK: - Header

    private var headerTitle: some View {
        Text("Analytics")
            .font(.headline.weight(.semibold))
            .foregroundColor(AppConstants.Colors.textPrimary)
            .padding(.top, 4)
    }

    // MARK: - Range picker

    private var rangePicker: some View {
        Picker("Range", selection: $viewModel.range) {
            ForEach(AnalyticsRange.allCases) { range in
                Text(range.displayName).tag(range)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Summary cards

    private var summaryCards: some View {
        HStack(spacing: 12) {
            summaryCard(
                title: "Income",
                value: viewModel.formattedIncome,
                icon: "arrow.down.circle.fill",
                color: AppConstants.Colors.income
            )
            summaryCard(
                title: "Expense",
                value: viewModel.formattedExpense,
                icon: "arrow.up.circle.fill",
                color: AppConstants.Colors.expense
            )
            summaryCard(
                title: "Net",
                value: viewModel.formattedNet,
                icon: "equal.circle.fill",
                color: viewModel.netCashFlow >= 0
                    ? AppConstants.Colors.income
                    : AppConstants.Colors.expense
            )
        }
    }

    private func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(title)
                .font(.caption)
                .foregroundColor(AppConstants.Colors.textSecondary)
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    // MARK: - Category bar chart

    private var categoryChartCard: some View {
        Group {
            if viewModel.categoryBreakdown.isEmpty {
                emptyState(text: "No spending in this period yet.")
            } else {
                Chart(viewModel.categoryBreakdown) { slice in
                    BarMark(
                        x: .value("Spend", slice.totalDouble),
                        y: .value("Category", slice.category.displayName)
                    )
                    .foregroundStyle(AppConstants.Colors.primary)
                    .cornerRadius(4)
                }
                .chartXAxis {
                    AxisMarks(format: FloatingPointFormatStyle<Double>.Currency(code: "AUD"))
                }
                .frame(height: max(220, CGFloat(viewModel.categoryBreakdown.count) * 36))
                .padding(16)
                .background(AppConstants.Colors.cardBackground)
                .cornerRadius(AppConstants.Layout.cardCornerRadius)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            }
        }
    }

    // MARK: - Monthly bar chart

    private var monthlyTrendCard: some View {
        Group {
            if viewModel.monthlyTrend.isEmpty {
                emptyState(text: "No monthly data yet.")
            } else {
                Chart {
                    ForEach(viewModel.monthlyTrend) { bucket in
                        BarMark(
                            x: .value("Month", bucket.month, unit: .month),
                            y: .value("Income", bucket.incomeDouble)
                        )
                        .foregroundStyle(AppConstants.Colors.income)
                        .position(by: .value("Type", "Income"))

                        BarMark(
                            x: .value("Month", bucket.month, unit: .month),
                            y: .value("Expense", bucket.expenseDouble)
                        )
                        .foregroundStyle(AppConstants.Colors.expense)
                        .position(by: .value("Type", "Expense"))
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 240)
                .padding(16)
                .background(AppConstants.Colors.cardBackground)
                .cornerRadius(AppConstants.Layout.cardCornerRadius)
                .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
            }
        }
    }

    // MARK: - Category list

    private var categoryListCard: some View {
        VStack(spacing: 0) {
            if viewModel.categoryBreakdown.isEmpty {
                emptyState(text: "Nothing to rank yet.")
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.categoryBreakdown) { slice in
                    HStack(spacing: 14) {
                        Image(systemName: slice.category.icon)
                            .foregroundColor(AppConstants.Colors.primary)
                            .frame(width: 38, height: 38)
                            .background(AppConstants.Colors.primary.opacity(0.12))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 3) {
                            Text(slice.category.displayName)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(AppConstants.Colors.textPrimary)
                            Text(percentageString(for: slice))
                                .font(.caption)
                                .foregroundColor(AppConstants.Colors.textSecondary)
                        }

                        Spacer()

                        Text(viewModel.formatted(slice.total))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)

                    if slice.id != viewModel.categoryBreakdown.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }
            }
        }
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private func percentageString(for slice: CategorySpend) -> String {
        let total = viewModel.categoryBreakdown.map(\.totalDouble).reduce(0, +)
        guard total > 0 else { return "0%" }
        let pct = slice.totalDouble / total * 100
        return String(format: "%.1f%% of spending", pct)
    }

    private func emptyState(text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(AppConstants.Colors.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(AppConstants.Layout.cardCornerRadius)
    }
}
