import SwiftUI
import Combine

struct PrivacySecurityView: View {
	
	@StateObject private var viewModel = PrivacySecurityViewModel()
	@State private var showingChangePassword = false
	@Environment(\.dismiss) private var dismiss
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				headerSection
				passwordSection
				biometricsSection
				dataPrivacySection
				dangerZoneSection
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			.padding(.top, 16)
		}
		.background(AppConstants.Colours.background.ignoresSafeArea())
		.navigationTitle("Privacy & Security")
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
		.sheet(isPresented: $showingChangePassword) {
			NavigationStack {
				ChangePasswordView()
			}
		}
	}
	
	// MARK: - Header
	
	private var headerSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Image(systemName: "lock.shield.fill")
					.font(.system(size: 32))
					.foregroundColor(AppConstants.Colours.primary)
				
				Spacer()
			}
			
			Text("Your data is safe with us")
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.textSecondary)
		}
		.padding(.vertical, 8)
	}
	
	// MARK: - Password Section
	
	private var passwordSection: some View {
		VStack(spacing: 0) {
			PrivacySectionHeader(title: "Security")
			
			SettingsCard {
				Button {
					showingChangePassword = true
				} label: {
					HStack {
						Image(systemName: "key.fill")
							.font(.system(size: 20))
							.foregroundColor(AppConstants.Colours.primary)
							.frame(width: 28)
						
						Text("Change Password")
							.font(.body)
							.foregroundColor(AppConstants.Colours.textPrimary)
						
						Spacer()
						
						Image(systemName: "chevron.right")
							.font(.system(size: 14, weight: .semibold))
							.foregroundColor(AppConstants.Colours.textSecondary)
					}
					.padding(16)
				}
			}
		}
	}
	
	// MARK: - Biometrics Section
	
	private var biometricsSection: some View {
		VStack(spacing: 0) {
			PrivacySectionHeader(title: "Biometric Authentication")
			
			SettingsCard {
				VStack(spacing: 0) {
					ToggleRow(
						icon: "faceid",
						title: "Face ID",
						subtitle: "Use Face ID to unlock the app",
						iconColor: AppConstants.Colours.primary,
						isOn: $viewModel.isFaceIDEnabled
					)
					
					Divider()
						.padding(.leading, 44)
					
					ToggleRow(
						icon: "touchid",
						title: "Touch ID",
						subtitle: "Use Touch ID to unlock the app",
						iconColor: AppConstants.Colours.primary,
						isOn: $viewModel.isTouchIDEnabled
					)
				}
			}
		}
	}
	
	// MARK: - Data Privacy Section
	
	private var dataPrivacySection: some View {
		VStack(spacing: 0) {
			PrivacySectionHeader(title: "Data & Privacy")
			
			SettingsCard {
				VStack(spacing: 0) {
					ActionRow(
						icon: "square.and.arrow.down",
						title: "Download Your Data",
						subtitle: "Export all your spending data",
						iconColor: AppConstants.Colours.primary
					) {
						viewModel.downloadData()
					}
					
					Divider()
						.padding(.leading, 44)
					
					ActionRow(
						icon: "trash",
						title: "Clear All Data",
						subtitle: "Remove all spending records",
						iconColor: AppConstants.Colours.error
					) {
						viewModel.showClearDataAlert = true
					}
				}
			}
		}
		.alert("Clear All Data?", isPresented: $viewModel.showClearDataAlert) {
			Button("Cancel", role: .cancel) { }
			Button("Clear Data", role: .destructive) {
				viewModel.clearAllData()
			}
		} message: {
			Text("This will permanently delete all your spending records. This action cannot be undone.")
		}
	}
	
	// MARK: - Danger Zone
	
	private var dangerZoneSection: some View {
		VStack(spacing: 0) {
			PrivacySectionHeader(title: "Danger Zone")
			
			SettingsCard {
				ActionRow(
					icon: "trash.fill",
					title: "Delete Account",
					subtitle: "Permanently delete your account",
					iconColor: AppConstants.Colours.error,
					showChevron: false
				) {
					viewModel.showDeleteAccountAlert = true
				}
			}
		}
		.alert("Delete Account?", isPresented: $viewModel.showDeleteAccountAlert) {
			Button("Cancel", role: .cancel) { }
			Button("Delete Account", role: .destructive) {
				viewModel.deleteAccount()
			}
		} message: {
			Text("This will permanently delete your account and all associated data. This action cannot be undone.")
		}
	}
}

// MARK: - Privacy Section Header

private struct PrivacySectionHeader: View {
	let title: String
	
	var body: some View {
		HStack {
			Text(title)
				.font(.headline)
				.foregroundColor(AppConstants.Colours.textPrimary)
			Spacer()
		}
		.padding(.bottom, 8)
	}
}

// MARK: - Toggle Row

private struct ToggleRow: View {
	let icon: String
	let title: String
	let subtitle: String
	let iconColor: Color
	@Binding var isOn: Bool
	
	var body: some View {
		HStack(spacing: 12) {
			Image(systemName: icon)
				.font(.system(size: 20))
				.foregroundColor(iconColor)
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

// MARK: - Action Row

private struct ActionRow: View {
	let icon: String
	let title: String
	let subtitle: String
	let iconColor: Color
	var showChevron: Bool = true
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				Image(systemName: icon)
					.font(.system(size: 20))
					.foregroundColor(iconColor)
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
				
				if showChevron {
					Image(systemName: "chevron.right")
						.font(.system(size: 14, weight: .semibold))
						.foregroundColor(AppConstants.Colours.textSecondary)
				}
			}
			.padding(16)
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
	}
}

// MARK: - Settings Card (reusable)

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

// MARK: - View Model

@MainActor
final class PrivacySecurityViewModel: ObservableObject {
	
	@Published var isFaceIDEnabled: Bool = false
	@Published var isTouchIDEnabled: Bool = false
	@Published var showClearDataAlert: Bool = false
	@Published var showDeleteAccountAlert: Bool = false
	
	func downloadData() {
		// In a real app, you would:
		// 1. Generate CSV/JSON export of user data
		// 2. Present share sheet to save/share file
		print("Downloading user data...")
	}
	
	func clearAllData() {
		// In a real app, you would:
		// 1. Delete all spending records from database
		// 2. Keep user account active
		print("Clearing all spending data...")
	}
	
	func deleteAccount() {
		// In a real app, you would:
		// 1. Call API to delete account
		// 2. Clear all local data
		// 3. Log user out
		// 4. Navigate to login screen
		print("Deleting account...")
	}
}

#Preview {
	NavigationStack {
		PrivacySecurityView()
	}
}
