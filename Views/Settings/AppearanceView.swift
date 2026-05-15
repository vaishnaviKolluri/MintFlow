import SwiftUI
import Combine

struct AppearanceView: View {
	
	@ObservedObject var appearanceManager = AppearanceManager.shared
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				headerSection
				themeSection
				colorSection
				displaySection
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			.padding(.top, 16)
		}
		.background(AppConstants.Colours.background.ignoresSafeArea())
		.navigationTitle("Appearance")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.font(.system(size: 16, weight: .semibold))
						.foregroundColor(AppConstants.Colours.textSecondary)
				}
			}
		}
	}
	
	// MARK: - Header
	
	private var headerSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Image(systemName: "paintbrush.fill")
					.font(.system(size: 32))
					.foregroundColor(AppConstants.Colours.primary)
				
				Spacer()
			}
			
			Text("Customize how MintFlow looks and feels")
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.textSecondary)
		}
		.padding(.vertical, 8)
	}
	
	// MARK: - Theme Section
	
	private var themeSection: some View {
		VStack(spacing: 12) {
			HStack {
				Text("Theme")
					.font(.headline)
					.foregroundColor(AppConstants.Colours.textPrimary)
				Spacer()
			}
			
			VStack(spacing: 12) {
				ThemeOption(
					title: "Light",
					icon: "sun.max.fill",
					isSelected: appearanceManager.selectedTheme == .light
				) {
					appearanceManager.selectedTheme = .light
				}
				
				ThemeOption(
					title: "Dark",
					icon: "moon.fill",
					isSelected: appearanceManager.selectedTheme == .dark
				) {
					appearanceManager.selectedTheme = .dark
				}
				
				ThemeOption(
					title: "System",
					icon: "circle.lefthalf.filled",
					isSelected: appearanceManager.selectedTheme == .system
				) {
					appearanceManager.selectedTheme = .system
				}
			}
		}
	}
	
	// MARK: - Color Section
	
	private var colorSection: some View {
		VStack(spacing: 12) {
			HStack {
				Text("Accent Color")
					.font(.headline)
					.foregroundColor(AppConstants.Colours.textPrimary)
				Spacer()
			}
			
			ScrollView(.horizontal, showsIndicators: false) {
				HStack(spacing: 12) {
					ForEach(AccentColorOption.allCases, id: \.self) { option in
						ColorOption(
							color: option.primaryColor,
							name: option.name,
							isSelected: appearanceManager.selectedAccentColor == option
						) {
							appearanceManager.selectedAccentColor = option
						}
					}
				}
				.padding(.horizontal, 2)
			}
		}
	}
	
	// MARK: - Display Section
	
	private var displaySection: some View {
		VStack(spacing: 0) {
			HStack {
				Text("Display Options")
					.font(.headline)
					.foregroundColor(AppConstants.Colours.textPrimary)
				Spacer()
			}
			.padding(.bottom, 12)
			
			SettingsCard {
				VStack(spacing: 0) {
					ToggleSettingRow(
						icon: "chart.bar.fill",
						title: "Show Charts",
						subtitle: "Display visual spending charts",
						isOn: $appearanceManager.showCharts
					)
					
					Divider()
						.padding(.leading, 44)
					
					ToggleSettingRow(
						icon: "sparkles",
						title: "Animations",
						subtitle: "Enable smooth transitions",
						isOn: $appearanceManager.enableAnimations
					)
					
					Divider()
						.padding(.leading, 44)
					
					ToggleSettingRow(
						icon: "number",
						title: "Compact Numbers",
						subtitle: "Show abbreviated amounts (e.g., 1.5K)",
						isOn: $appearanceManager.useCompactNumbers
					)
				}
			}
		}
	}
}

// MARK: - Theme Option

private struct ThemeOption: View {
	let title: String
	let icon: String
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			HStack(spacing: 16) {
				Image(systemName: icon)
					.font(.system(size: 24))
					.foregroundColor(isSelected ? AppConstants.Colours.primary : AppConstants.Colours.textSecondary)
					.frame(width: 40)
				
				Text(title)
					.font(.body.weight(isSelected ? .semibold : .regular))
					.foregroundColor(AppConstants.Colours.textPrimary)
				
				Spacer()
				
				if isSelected {
					Image(systemName: "checkmark.circle.fill")
						.font(.system(size: 20))
						.foregroundColor(AppConstants.Colours.primary)
				} else {
					Image(systemName: "circle")
						.font(.system(size: 20))
						.foregroundColor(AppConstants.Colours.textSecondary)
				}
			}
			.padding(16)
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cornerRadius)
			.overlay(
				RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
					.stroke(
						isSelected ? AppConstants.Colours.primary : AppConstants.Colours.divider,
						lineWidth: isSelected ? 2 : 1
					)
			)
		}
		.buttonStyle(.plain)
	}
}

// MARK: - Color Option

private struct ColorOption: View {
	let color: Color
	let name: String
	let isSelected: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			VStack(spacing: 8) {
				ZStack {
					Circle()
						.fill(color)
						.frame(width: 50, height: 50)
					
					if isSelected {
						Circle()
							.stroke(.white, lineWidth: 3)
							.frame(width: 50, height: 50)
						
						Image(systemName: "checkmark")
							.font(.system(size: 20, weight: .bold))
							.foregroundColor(.white)
					}
				}
				
				Text(name)
					.font(.caption.weight(isSelected ? .semibold : .regular))
					.foregroundColor(AppConstants.Colours.textPrimary)
			}
			.padding(.vertical, 8)
		}
		.buttonStyle(.plain)
	}
}

// MARK: - Toggle Setting Row

private struct ToggleSettingRow: View {
	let icon: String
	let title: String
	let subtitle: String
	@Binding var isOn: Bool
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 20))
				.foregroundColor(AppConstants.Colours.primary)
				.frame(width: 28)
			
			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.body)
					.foregroundColor(AppConstants.Colours.textPrimary)
				
				Text(subtitle)
					.font(.caption)
					.foregroundColor(AppConstants.Colours.textSecondary)
			}
			
			Spacer()
			
			Toggle("", isOn: $isOn)
				.labelsHidden()
		}
		.padding(16)
	}
}

// MARK: - Settings Card

private struct SettingsCard<Content: View>: View {
	let content: Content
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		content
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cardCornerRadius)
			.overlay(
				RoundedRectangle(cornerRadius: AppConstants.Layout.cardCornerRadius)
					.stroke(AppConstants.Colours.divider, lineWidth: 1)
			)
	}
}

#Preview {
	NavigationStack {
		AppearanceView()
	}
}
