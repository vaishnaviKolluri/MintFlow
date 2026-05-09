import SwiftUI

struct SpendingTrackerView: View {

	@StateObject private var viewModel: SpendingTrackerViewModel
	@State private var isPresentingAddSpend: Bool = false

	init(user: User) {
		_viewModel = StateObject(wrappedValue: SpendingTrackerViewModel(user: user))
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				headerBar
				summaryStrip
				filterSection
				categorySection
				spendsList
				Spacer(minLength: 0)
			}
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
				Text("Spending")
					.font(.title2.weight(.bold))
					.foregroundColor(AppConstants.Colours.textPrimary)
				Text("Every coin, accounted for")
					.font(.subheadline)
					.foregroundColor(AppConstants.Colours.textSecondary)
			}
			Spacer()
			Button {
				isPresentingAddSpend = true
			} label: {
				HStack(spacing: 6) {
					Image(systemName: "plus")
						.font(.subheadline.weight(.bold))
					Text("Add")
						.font(.subheadline.weight(.semibold))
				}
				.foregroundColor(.white)
				.padding(.horizontal, 14)
				.padding(.vertical, 9)
				.background(AppConstants.Colours.primary)
				.cornerRadius(999)
				.shadow(color: AppConstants.Colours.primary.opacity(0.3), radius: 6, y: 3)
			}
			.buttonStyle(.plain)
		}
		.padding(.horizontal, AppConstants.Layout.horizontalPadding)
	}

	private var summaryStrip: some View {
		HStack(spacing: AppConstants.Layout.tileSpacing) {
			StatTile(
				title: "Filtered total",
				value: viewModel.formattedFilteredTotal,
				caption: "\(viewModel.spendCount) spends",
				iconName: "creditcard.fill"
			)
			StatTile(
				title: "View",
				value: viewModel.selectedFilter.displayName,
				caption: viewModel.selectedCategory?.displayName ?? "All categories",
				iconName: "line.3.horizontal.decrease.circle.fill",
				accentColour: AppConstants.Colours.accent
			)
		}
		.padding(.horizontal, AppConstants.Layout.horizontalPadding)
	}

	private var filterSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Time")
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)
				.padding(.horizontal, AppConstants.Layout.horizontalPadding)

			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 8) {
					ForEach(SpendingFilter.allCases) { filter in
						CategoryChip(
							iconName: nil,
							label: filter.displayName,
							isSelected: viewModel.selectedFilter == filter,
							onTap: { viewModel.selectedFilter = filter }
						)
					}
				}
				.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			}
		}
	}

	private var categorySection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Category")
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)
				.padding(.horizontal, AppConstants.Layout.horizontalPadding)

			CategoryChipsRow(
				categories: Category.allCases.filter { $0 != .income },
				selectedCategory: $viewModel.selectedCategory
			)
		}
	}

	private var spendsList: some View {
		VStack(spacing: 16) {
			if let errorMessage = viewModel.errorMessage {
				ErrorBanner(message: errorMessage)
					.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			}

			if viewModel.sections.isEmpty {
				emptyState
			} else {
				ForEach(viewModel.sections) { section in
					daySection(section)
				}
			}
		}
	}

	private func daySection(_ section: SpendingDaySection) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text(section.displayLabel)
					.font(.caption.weight(.semibold))
					.foregroundColor(AppConstants.Colours.textSecondary)
				Spacer()
				Text(CurrencyFormatter.format(section.totalForDay))
					.font(.caption.weight(.semibold))
					.foregroundColor(AppConstants.Colours.textSecondary)
					.monospacedDigit()
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)

			VStack(spacing: 0) {
				ForEach(Array(section.spends.enumerated()), id: \.element.identifier) { offset, spend in
					SpendRow(spend: spend)
						.contextMenu {
							Button(role: .destructive) {
								Task { await viewModel.deleteSpend(spend) }
							} label: {
								Label("Delete", systemImage: "trash")
							}
						}
					if offset < section.spends.count - 1 {
						Divider()
							.padding(.leading, 70)
					}
				}
			}
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cardCornerRadius)
			.shadow(color: .black.opacity(0.04), radius: 4, y: 2)
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
		}
	}

	private var emptyState: some View {
		VStack(spacing: 12) {
			Image(systemName: "leaf.circle")
				.font(.system(size: 44))
				.foregroundColor(AppConstants.Colours.primary)
			Text("No spends to show here")
				.font(.subheadline.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textPrimary)
			Text("Try a different filter, or log your first spend.")
				.font(.caption)
				.foregroundColor(AppConstants.Colours.textSecondary)
				.multilineTextAlignment(.center)
		}
		.padding(28)
		.frame(maxWidth: .infinity)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cardCornerRadius)
		.shadow(color: .black.opacity(0.04), radius: 4, y: 2)
		.padding(.horizontal, AppConstants.Layout.horizontalPadding)
	}
}
