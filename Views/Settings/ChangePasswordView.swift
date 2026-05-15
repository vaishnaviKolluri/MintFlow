import SwiftUI
import Combine

struct ChangePasswordView: View {
	
	@Environment(\.dismiss) private var dismiss
	@StateObject private var viewModel = ChangePasswordViewModel()
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				headerSection
				passwordFields
				requirementsSection
				
				if let error = viewModel.errorMessage {
					ErrorBanner(message: error)
				}
				
				saveButton
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			.padding(.top, 16)
		}
		.background(AppConstants.Colours.background.ignoresSafeArea())
		.navigationTitle("Change Password")
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
			Image(systemName: "lock.rotation")
				.font(.system(size: 32))
				.foregroundColor(AppConstants.Colours.primary)
			
			Text("Create a strong password to keep your account secure")
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.textSecondary)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, 8)
	}
	
	// MARK: - Password Fields
	
	private var passwordFields: some View {
		VStack(spacing: 16) {
			PasswordField(
				label: "Current Password",
				placeholder: "Enter current password",
				text: $viewModel.currentPassword
			)
			
			PasswordField(
				label: "New Password",
				placeholder: "Enter new password",
				text: $viewModel.newPassword
			)
			
			PasswordField(
				label: "Confirm New Password",
				placeholder: "Confirm new password",
				text: $viewModel.confirmPassword
			)
		}
	}
	
	// MARK: - Requirements
	
	private var requirementsSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Password Requirements")
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)
			
			RequirementRow(
				text: "At least 8 characters",
				isMet: viewModel.meetsLengthRequirement
			)
			
			RequirementRow(
				text: "Contains uppercase letter",
				isMet: viewModel.meetsUppercaseRequirement
			)
			
			RequirementRow(
				text: "Contains lowercase letter",
				isMet: viewModel.meetsLowercaseRequirement
			)
			
			RequirementRow(
				text: "Contains a number",
				isMet: viewModel.meetsNumberRequirement
			)
		}
		.padding(16)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cornerRadius)
	}
	
	// MARK: - Save Button
	
	private var saveButton: some View {
		PrimaryButton("Change Password", isLoading: viewModel.isSaving) {
			Task {
				if await viewModel.changePassword() {
					dismiss()
				}
			}
		}
	}
}

// MARK: - Password Field

private struct PasswordField: View {
	let label: String
	let placeholder: String
	@Binding var text: String
	@State private var isSecure: Bool = true
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(label)
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)
			
			HStack(spacing: 12) {
				Image(systemName: "lock.fill")
					.font(.system(size: 18))
					.foregroundColor(AppConstants.Colours.primary)
					.frame(width: 24)
				
				Group {
					if isSecure {
						SecureField(placeholder, text: $text)
					} else {
						TextField(placeholder, text: $text)
					}
				}
				.font(.body)
				.foregroundColor(AppConstants.Colours.textPrimary)
				
				Button {
					isSecure.toggle()
				} label: {
					Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
						.font(.system(size: 16))
						.foregroundColor(AppConstants.Colours.textSecondary)
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 14)
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cornerRadius)
			.overlay(
				RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
					.stroke(AppConstants.Colours.divider, lineWidth: 1)
			)
		}
	}
}

// MARK: - Requirement Row

private struct RequirementRow: View {
	let text: String
	let isMet: Bool
	
	var body: some View {
		HStack(spacing: 8) {
			Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
				.font(.system(size: 16))
				.foregroundColor(isMet ? AppConstants.Colours.income : AppConstants.Colours.textSecondary)
			
			Text(text)
				.font(.caption)
				.foregroundColor(isMet ? AppConstants.Colours.textPrimary : AppConstants.Colours.textSecondary)
			
			Spacer()
		}
	}
}

// MARK: - View Model

@MainActor
final class ChangePasswordViewModel: ObservableObject {
	
	@Published var currentPassword: String = ""
	@Published var newPassword: String = ""
	@Published var confirmPassword: String = ""
	@Published var isSaving: Bool = false
	@Published var errorMessage: String?
	
	var meetsLengthRequirement: Bool {
		newPassword.count >= 8
	}
	
	var meetsUppercaseRequirement: Bool {
		newPassword.range(of: "[A-Z]", options: .regularExpression) != nil
	}
	
	var meetsLowercaseRequirement: Bool {
		newPassword.range(of: "[a-z]", options: .regularExpression) != nil
	}
	
	var meetsNumberRequirement: Bool {
		newPassword.range(of: "[0-9]", options: .regularExpression) != nil
	}
	
	var meetsAllRequirements: Bool {
		meetsLengthRequirement &&
		meetsUppercaseRequirement &&
		meetsLowercaseRequirement &&
		meetsNumberRequirement
	}
	
	func changePassword() async -> Bool {
		errorMessage = nil
		
		// Validate fields
		guard !currentPassword.isEmpty else {
			errorMessage = "Please enter your current password"
			return false
		}
		
		guard !newPassword.isEmpty else {
			errorMessage = "Please enter a new password"
			return false
		}
		
		guard meetsAllRequirements else {
			errorMessage = "New password doesn't meet all requirements"
			return false
		}
		
		guard newPassword == confirmPassword else {
			errorMessage = "New passwords don't match"
			return false
		}
		
		guard newPassword != currentPassword else {
			errorMessage = "New password must be different from current password"
			return false
		}
		
		isSaving = true
		
		// Simulate API call
		try? await Task.sleep(for: .seconds(1))
		
		// In a real app, you would:
		// 1. Call your API to change password
		// 2. Verify current password
		// 3. Update to new password
		// 4. Handle success/error
		
		isSaving = false
		
		return true
	}
}

#Preview {
	NavigationStack {
		ChangePasswordView()
	}
}
