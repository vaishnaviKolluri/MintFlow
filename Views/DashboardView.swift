import SwiftUI

struct DashboardView: View {

	@EnvironmentObject var appViewModel: AppViewModel
	@StateObject private var viewModel: DashboardViewModel
	@State private var isPresentingAddSpend: Bool = false

	init(user: User) {
		_viewModel = StateObject(wrappedValue: DashboardViewModel(user: user))
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				headerBar
				totalSpendCard
				statsRow
				monthlyTrendSection
				categoryBreakdownSection
				recentSpendsSection
				Spacer(minLength: 0)
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			.padding(.top, 16)
		}
		.background(AppConstants.Colours.background.ignoresSafeArea())
		.refreshable { await viewModel.refresh() }
		.task { await viewModel.load() }
		.sheet(isPresented: $isPresentingAddSpend) {
			AddSpendView(user: viewModel.user) {
				Task { await viewModel.refresh() }
			}
		}
	}

	private var headerBar: some View {
		HStack(alignment: .top) {
			VStack(alignment: .leading, spacing: 4) {
				Text("Hello, \(viewModel.greetingFirstName)")
					.font(.title2.weight(.bold))
					.foregroundColor(AppConstants.Colours.textPrimary)
				Text("Here is how your spending is flowing")
					.font(.subheadline)
					.foregroundColor(AppConstants.Colours.textSecondary)
			}
			Spacer()
			Button {
				appViewModel.logout()
			} label: {
				Image(systemName: "rectangle.portrait.and.arrow.right")
					.font(.subheadline.weight(.semibold))
					.foregroundColor(AppConstants.Colours.textSecondary)
					.frame(width: 38, height: 38)
					.background(AppConstants.Colours.cardBackground)
					.clipShape(Circle())
					.shadow(color: .black.opacity(0.06), radius: 4, y: 2)
			}
		}
	}

	private var totalSpendCard: some View {
		VStack(alignment: .leading, spacing: 18) {
			HStack {
				VStack(alignment: .leading, spacing: 4) {
					Text("This month")
						.font(.caption.weight(.medium))
						.foregroundColor(.white.opacity(0.85))
					Text(viewModel.formattedThisMonthTotal)
						.font(.system(size: 38, weight: .bold, design: .rounded))
						.foregroundColor(.white)
						.lineLimit(1)
						.minimumScaleFactor(0.6)
				}
				Spacer()

				if let summary = viewModel.summary {
					trendBadge(direction: viewModel.monthOverMonthDirection, summary: summary)
				}
			}

			Button {
				isPresentingAddSpend = true
			} label: {
				HStack(spacing: 8) {
					Image(systemName: "plus.circle.fill")
					Text("Log a spend")
						.fontWeight(.semibold)
				}
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.primaryDark)
				.padding(.horizontal, 16)
				.padding(.vertical, 10)
				.background(Color.white)
				.cornerRadius(999)
			}
			.buttonStyle(.plain)
		}
		.padding(22)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(
			LinearGradient(
				colors: [AppConstants.Colours.primary, AppConstants.Colours.primaryDark],
				startPoint: .topLeading,
				endPoint: .bottomTrailing
			)
		)
		.cornerRadius(AppConstants.Layout.cardCornerRadius)
		.shadow(color: AppConstants.Colours.primary.opacity(0.25), radius: 14, y: 6)
	}

	private func trendBadge(direction: TrendDirection, summary: SpendingSummary) -> some View {
		let absoluteChange = abs(NSDecimalNumber(decimal: summary.totalThisMonth - summary.totalLastMonth).doubleValue)
		let label = CurrencyFormatter.format(absoluteChange)

		return HStack(spacing: 6) {
			Image(systemName: direction.iconName)
				.font(.caption.weight(.bold))
			Text(label)
				.font(.caption.weight(.semibold))
		}
		.foregroundColor(.white)
		.padding(.horizontal, 10)
		.padding(.vertical, 6)
		.background(Color.white.opacity(0.18))
		.cornerRadius(999)
	}

	private var statsRow: some View {
		HStack(spacing: AppConstants.Layout.tileSpacing) {
			StatTile(
				title: "Daily average",
				value: viewModel.formattedDailyAverage,
				caption: "This month so far",
				iconName: "calendar"
			)
			StatTile(
				title: "Last month",
				value: viewModel.formattedLastMonthTotal,
				caption: "Total spent",
				iconName: "clock.arrow.circlepath",
				accentColour: AppConstants.Colours.accent
			)
		}
	}

	private var monthlyTrendSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			SectionHeader(title: "Monthly trend")

			VStack(alignment: .leading, spacing: 8) {
				if viewModel.monthlyTotals.allSatisfy({ $0.total == 0 }) {
					emptyState(message: "No spending recorded yet. Tap Log a spend to get started.")
				} else {
					MonthlyTrendChart(monthlyTotals: viewModel.monthlyTotals)
				}
			}
			.padding(16)
			.frame(maxWidth: .infinity)
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cardCornerRadius)
			.shadow(color: .black.opacity(0.05), radius: 6, y: 2)
		}
	}

	private var categoryBreakdownSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			SectionHeader(title: "Where your money went")

			if viewModel.categoryBreakdown.isEmpty {
				emptyState(message: "Nothing to summarise this month yet.")
					.padding(16)
					.frame(maxWidth: .infinity)
					.background(AppConstants.Colours.cardBackground)
					.cornerRadius(AppConstants.Layout.cardCornerRadius)
					.shadow(color: .black.opacity(0.05), radius: 6, y: 2)
			} else {
				CategoryBreakdownList(breakdown: viewModel.categoryBreakdown)
			}
		}
	}

	private var recentSpendsSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			SectionHeader(title: "Recent spends")

			if viewModel.recentSpends.isEmpty {
				emptyState(message: "No recent spends to show.")
					.padding(16)
					.frame(maxWidth: .infinity)
					.background(AppConstants.Colours.cardBackground)
					.cornerRadius(AppConstants.Layout.cardCornerRadius)
					.shadow(color: .black.opacity(0.05), radius: 6, y: 2)
			} else {
				VStack(spacing: 0) {
					ForEach(Array(viewModel.recentSpends.enumerated()), id: \.element.identifier) { offset, spend in
						SpendRow(spend: spend, showsRelativeTime: true)
						if offset < viewModel.recentSpends.count - 1 {
							Divider()
								.padding(.leading, 70)
						}
					}
				}
				.background(AppConstants.Colours.cardBackground)
				.cornerRadius(AppConstants.Layout.cardCornerRadius)
				.shadow(color: .black.opacity(0.05), radius: 6, y: 2)
			}
		}
	}

	private func emptyState(message: String) -> some View {
		HStack(spacing: 10) {
			Image(systemName: "leaf")
				.foregroundColor(AppConstants.Colours.primary)
			Text(message)
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.textSecondary)
			Spacer()
		}
	}
}
