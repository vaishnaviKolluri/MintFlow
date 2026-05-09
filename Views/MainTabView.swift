import SwiftUI

struct MainTabView: View {

	@EnvironmentObject var appViewModel: AppViewModel
	@State private var selectedTab: MainTab = .dashboard

	var body: some View {
		let user = appViewModel.currentUser ?? User(email: "demo@mintflow.app", fullName: "Demo User")

		ZStack(alignment: .bottom) {
			AppConstants.Colours.background.ignoresSafeArea()

			Group {
				switch selectedTab {
				case .dashboard:
					DashboardView(user: user)
				case .spending:
					SpendingTrackerView(user: user)
				}
			}
			.padding(.bottom, 80)

			MainTabBar(selectedTab: $selectedTab)
				.padding(.horizontal, AppConstants.Layout.horizontalPadding)
				.padding(.bottom, 14)
		}
	}
}

enum MainTab: String, CaseIterable, Identifiable {
	case dashboard
	case spending

	var id: String { rawValue }

	var displayName: String {
		switch self {
		case .dashboard:	return "Dashboard"
		case .spending:		return "Spending"
		}
	}

	var iconName: String {
		switch self {
		case .dashboard:	return "chart.pie.fill"
		case .spending:		return "list.bullet.rectangle.portrait.fill"
		}
	}
}

private struct MainTabBar: View {

	@Binding var selectedTab: MainTab

	var body: some View {
		HStack(spacing: 8) {
			ForEach(MainTab.allCases) { tab in
				let isSelected = tab == selectedTab

				Button {
					withAnimation(.easeInOut(duration: 0.2)) {
						selectedTab = tab
					}
				} label: {
					HStack(spacing: 8) {
						Image(systemName: tab.iconName)
							.font(.subheadline.weight(.semibold))
						if isSelected {
							Text(tab.displayName)
								.font(.subheadline.weight(.semibold))
						}
					}
					.foregroundColor(isSelected ? .white : AppConstants.Colours.textSecondary)
					.padding(.vertical, 12)
					.frame(maxWidth: .infinity)
					.background(isSelected ? AppConstants.Colours.primary : Color.clear)
					.cornerRadius(999)
				}
				.buttonStyle(.plain)
			}
		}
		.padding(6)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(999)
		.shadow(color: .black.opacity(0.08), radius: 12, y: 4)
	}
}
