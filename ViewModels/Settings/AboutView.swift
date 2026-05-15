import SwiftUI

struct AboutView: View {
	
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		ScrollView {
			VStack(spacing: 32) {
				appIconSection
				versionSection
				featuresSection
				creditsSection
				linksSection
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			.padding(.top, 16)
		}
		.background(AppConstants.Colours.background.ignoresSafeArea())
		.navigationTitle("About MintFlow")
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
	
	// MARK: - App Icon
	
	private var appIconSection: some View {
		VStack(spacing: 16) {
			ZStack {
				RoundedRectangle(cornerRadius: 24)
					.fill(
						LinearGradient(
							colors: [
								AppConstants.Colours.primary,
								AppConstants.Colours.primaryDark
							],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
					)
					.frame(width: 100, height: 100)
				
				Image(systemName: "leaf.circle.fill")
					.font(.system(size: 50))
					.foregroundColor(.white)
			}
			.shadow(color: AppConstants.Colours.primary.opacity(0.3), radius: 20, y: 10)
			
			Text(AppConstants.appName)
				.font(.system(size: 32, weight: .bold, design: .rounded))
				.foregroundColor(AppConstants.Colours.textPrimary)
			
			Text(AppConstants.appTagline)
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.textSecondary)
				.multilineTextAlignment(.center)
		}
		.padding(.vertical, 16)
	}
	
	// MARK: - Version
	
	private var versionSection: some View {
		VStack(spacing: 8) {
			HStack {
				Text("Version")
					.foregroundColor(AppConstants.Colours.textSecondary)
				Spacer()
				Text("1.0.0")
					.fontWeight(.medium)
					.foregroundColor(AppConstants.Colours.textPrimary)
			}
			.font(.subheadline)
			
			Divider()
			
			HStack {
				Text("Build")
					.foregroundColor(AppConstants.Colours.textSecondary)
				Spacer()
				Text("2026.05.14")
					.fontWeight(.medium)
					.foregroundColor(AppConstants.Colours.textPrimary)
			}
			.font(.subheadline)
		}
		.padding(16)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cardCornerRadius)
		.overlay(
			RoundedRectangle(cornerRadius: AppConstants.Layout.cardCornerRadius)
				.stroke(AppConstants.Colours.divider, lineWidth: 1)
		)
	}
	
	// MARK: - Features
	
	private var featuresSection: some View {
		VStack(spacing: 16) {
			HStack {
				Text("What's New")
					.font(.headline)
					.foregroundColor(AppConstants.Colours.textPrimary)
				Spacer()
			}
			
			VStack(spacing: 12) {
				FeatureRow(
					icon: "chart.pie.fill",
					title: "Smart Dashboard",
					description: "Visual insights into your spending"
				)
				
				FeatureRow(
					icon: "bell.fill",
					title: "Smart Notifications",
					description: "Daily reminders and budget alerts"
				)
				
				FeatureRow(
					icon: "list.bullet.rectangle.portrait.fill",
					title: "Spending Tracker",
					description: "Track every dollar you spend"
				)
				
				FeatureRow(
					icon: "chart.bar.fill",
					title: "Category Analysis",
					description: "See where your money goes"
				)
			}
		}
	}
	
	// MARK: - Credits
	
	private var creditsSection: some View {
		VStack(spacing: 12) {
			HStack {
				Text("Made with")
					.font(.subheadline)
					.foregroundColor(AppConstants.Colours.textSecondary)
				
				Image(systemName: "heart.fill")
					.font(.subheadline)
					.foregroundColor(AppConstants.Colours.error)
				
				Text("for smart spenders")
					.font(.subheadline)
					.foregroundColor(AppConstants.Colours.textSecondary)
			}
			
			Text("© 2026 MintFlow. All rights reserved.")
				.font(.caption)
				.foregroundColor(AppConstants.Colours.textSecondary)
		}
	}
	
	// MARK: - Links
	
	private var linksSection: some View {
		VStack(spacing: 12) {
			LinkButton(
				icon: "star.fill",
				title: "Rate MintFlow",
				subtitle: "Help us improve"
			) {
				// Open App Store rating
			}
			
			LinkButton(
				icon: "square.and.arrow.up",
				title: "Share MintFlow",
				subtitle: "Tell your friends"
			) {
				// Share sheet
			}
			
			LinkButton(
				icon: "envelope.fill",
				title: "Contact Support",
				subtitle: "We're here to help"
			) {
				// Open email
			}
		}
	}
}

// MARK: - Feature Row

private struct FeatureRow: View {
	let icon: String
	let title: String
	let description: String
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 20))
				.foregroundColor(AppConstants.Colours.primary)
				.frame(width: 32, height: 32)
				.background(AppConstants.Colours.primarySoft)
				.cornerRadius(8)
			
			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.body.weight(.medium))
					.foregroundColor(AppConstants.Colours.textPrimary)
				
				Text(description)
					.font(.caption)
					.foregroundColor(AppConstants.Colours.textSecondary)
			}
			
			Spacer()
		}
		.padding(12)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cornerRadius)
		.overlay(
			RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
				.stroke(AppConstants.Colours.divider, lineWidth: 1)
		)
	}
}

// MARK: - Link Button

private struct LinkButton: View {
	let icon: String
	let title: String
	let subtitle: String
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
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
				
				Image(systemName: "chevron.right")
					.font(.system(size: 14, weight: .semibold))
					.foregroundColor(AppConstants.Colours.textSecondary)
			}
			.padding(16)
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cardCornerRadius)
			.overlay(
				RoundedRectangle(cornerRadius: AppConstants.Layout.cardCornerRadius)
					.stroke(AppConstants.Colours.divider, lineWidth: 1)
			)
		}
		.buttonStyle(.plain)
	}
}

#Preview {
	NavigationStack {
		AboutView()
	}
}
