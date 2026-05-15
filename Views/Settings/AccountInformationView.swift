import SwiftUI
import Combine

struct AccountInformationView: View {
	
	let user: User
    @EnvironmentObject private var appViewModel: AppViewModel   
	@Environment(\.dismiss) private var dismiss
	@StateObject private var viewModel: AccountInformationViewModel
	
	init(user: User) {
		self.user = user
		_viewModel = StateObject(wrappedValue: AccountInformationViewModel(user: user))
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				profilePhotoSection
				accountDetailsSection
				
				if viewModel.isEditing {
					saveButton
				}
				
				if viewModel.showSuccess {
					successBanner
				}
				
				if let error = viewModel.errorMessage {
					ErrorBanner(message: error)
				}
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			.padding(.top, 16)
		}
		.background(AppConstants.Colours.background.ignoresSafeArea())
		.navigationTitle("Account Information")
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					dismiss()
				} label: {
					Image(systemName: "xmark")
						.font(.system(size: 16, weight: .semibold))
						.foregroundColor(AppConstants.Colours.textSecondary)
				}
			}
			
			ToolbarItem(placement: .topBarTrailing) {
				Button(viewModel.isEditing ? "Cancel" : "Edit") {
					viewModel.toggleEditing()
				}
			}
		}
	}
	
	// MARK: - Profile Photo Section
	
	private var profilePhotoSection: some View {
		VStack(spacing: 16) {
			ZStack {
				Circle()
					.fill(AppConstants.Colours.primarySoft)
					.frame(width: 100, height: 100)
				
				Text(user.fullName.prefix(1).uppercased())
					.font(.system(size: 40, weight: .bold, design: .rounded))
					.foregroundColor(AppConstants.Colours.primary)
			}
			
			if viewModel.isEditing {
				Button("Change Photo") {
					// Photo picker would go here
				}
				.font(.subheadline.weight(.medium))
				.foregroundColor(AppConstants.Colours.primary)
			}
		}
		.padding(.vertical, 8)
	}
	
	// MARK: - Account Details
	
	private var accountDetailsSection: some View {
		VStack(spacing: 16) {
			// Full Name
			AccountField(
				label: "Full Name",
				icon: "person.fill",
				text: $viewModel.fullName,
				isEditing: viewModel.isEditing
			)
			
			// Email
			AccountField(
				label: "Email",
				icon: "envelope.fill",
				text: $viewModel.email,
				isEditing: viewModel.isEditing,
				keyboardType: .emailAddress
			)
			
			// Member Since
			AccountField(
				label: "Member Since",
				icon: "calendar",
				text: .constant(viewModel.memberSinceFormatted),
				isEditing: false
			)
			
			// Account ID (for support)
			AccountField(
				label: "Account ID",
				icon: "number",
				text: .constant(user.id.uuidString.prefix(8).uppercased()),
				isEditing: false
			)
		}
	}
	
	// MARK: - Save Button
	
	private var saveButton: some View {
		PrimaryButton("Save Changes", isLoading: viewModel.isSaving) {
			Task {
                await viewModel.saveChanges(appViewModel: appViewModel)
			}
		}
	}
	
	// MARK: - Success Banner
	
	private var successBanner: some View {
		HStack {
			Image(systemName: "checkmark.circle.fill")
				.foregroundColor(.white)
			
			Text("Changes saved successfully")
				.font(.subheadline.weight(.medium))
				.foregroundColor(.white)
			
			Spacer()
		}
		.padding(16)
		.background(AppConstants.Colours.income)
		.cornerRadius(AppConstants.Layout.cornerRadius)
		.transition(.move(edge: .top).combined(with: .opacity))
	}
}

// MARK: - Account Field

private struct AccountField: View {
	
	let label: String
	let icon: String
	@Binding var text: String
	let isEditing: Bool
	var keyboardType: UIKeyboardType = .default
	
	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(label)
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)
			
			HStack(spacing: 12) {
				Image(systemName: icon)
					.font(.system(size: 18))
					.foregroundColor(AppConstants.Colours.primary)
					.frame(width: 24)
				
				if isEditing {
					TextField(label, text: $text)
						.font(.body)
						.foregroundColor(AppConstants.Colours.textPrimary)
						.keyboardType(keyboardType)
						.autocapitalization(keyboardType == .emailAddress ? .none : .words)
				} else {
					Text(text)
						.font(.body)
						.foregroundColor(AppConstants.Colours.textPrimary)
				}
			}
			.padding(.horizontal, 16)
			.padding(.vertical, 14)
			.background(isEditing ? AppConstants.Colours.cardBackground : AppConstants.Colours.background)
			.cornerRadius(AppConstants.Layout.cornerRadius)
			.overlay(
				RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
					.stroke(AppConstants.Colours.divider, lineWidth: isEditing ? 1 : 0)
			)
		}
	}
}

// MARK: - View Model

@MainActor
final class AccountInformationViewModel: ObservableObject {
	
	@Published var fullName: String
	@Published var email: String
	@Published var isEditing: Bool = false
	@Published var isSaving: Bool = false
	@Published var showSuccess: Bool = false
	@Published var errorMessage: String?
	
	private let user: User
	private let originalFullName: String
	private let originalEmail: String
	
	var memberSinceFormatted: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .long
		return formatter.string(from: user.createdAt)
	}
	
	init(user: User) {
		self.user = user
		self.fullName = user.fullName
		self.email = user.email
		self.originalFullName = user.fullName
		self.originalEmail = user.email
	}
	
	func toggleEditing() {
		if isEditing {
			// Cancel editing - restore original values
			fullName = originalFullName
			email = originalEmail
		}
		isEditing.toggle()
	}
	
    func saveChanges(appViewModel: AppViewModel) async {
        guard validateFields() else { return }
        
        isSaving = true
        errorMessage = nil
        
        do {
            // Call the AppViewModel to update the user
            try await appViewModel.updateUser(fullName: fullName, email: email)
            
            isSaving = false
            isEditing = false
            showSuccess = true
            
            // Hide success message after 3 seconds
            Task {
                try? await Task.sleep(for: .seconds(3))
                showSuccess = false
            }
        } catch AuthError.userAlreadyExists {
            errorMessage = "This email is already in use"
            isSaving = false
        } catch {
            errorMessage = "Failed to save changes. Please try again."
            isSaving = false
        }
    }
	
	private func validateFields() -> Bool {
		if fullName.trimmingCharacters(in: .whitespaces).isEmpty {
			errorMessage = "Please enter your full name"
			return false
		}
		
		if email.trimmingCharacters(in: .whitespaces).isEmpty {
			errorMessage = "Please enter your email"
			return false
		}
		
		if !email.contains("@") || !email.contains(".") {
			errorMessage = "Please enter a valid email address"
			return false
		}
		
		return true
	}
}

#Preview {
    NavigationStack {
        AccountInformationView(user: User(email: "demo@mintflow.app", fullName: "Demo User"))
            .environmentObject(AppViewModel())
    }
}
