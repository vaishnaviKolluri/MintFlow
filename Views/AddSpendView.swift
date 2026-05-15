import SwiftUI

struct AddSpendView: View {

	@Environment(\.dismiss) private var dismiss
	@StateObject private var viewModel: AddSpendViewModel

	init(user: User, onSavedSpend: @escaping () -> Void = {}) {
		_viewModel = StateObject(
			wrappedValue: AddSpendViewModel(
				user: user,
				onSavedSpend: { _ in onSavedSpend() }
			)
		)
	}

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 20) {
					AmountField(amountText: $viewModel.amountText)

					descriptionField

					categoryGrid

					datePickerCard

					if let errorMessage = viewModel.errorMessage {
						ErrorBanner(message: errorMessage)
					}

					saveButton
				}
				.padding(AppConstants.Layout.horizontalPadding)
			}
			.background(AppConstants.Colours.background.ignoresSafeArea())
			.navigationTitle("New spend")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						dismiss()
					}
					.foregroundColor(AppConstants.Colours.textSecondary)
				}
			}
		}
	}

	private var descriptionField: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Description")
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)

			TextField("e.g. Coffee with Sam", text: $viewModel.summaryText)
				.font(.body)
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

	private var categoryGrid: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Category")
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)

			LazyVGrid(
				columns: [GridItem(.adaptive(minimum: 100), spacing: 10)],
				spacing: 10
			) {
				ForEach(viewModel.availableCategories) { category in
					CategoryChip(
						category: category,
						isSelected: viewModel.selectedCategory == category,
						onTap: { viewModel.selectedCategory = category }
					)
				}
			}
		}
	}

	private var datePickerCard: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("When")
				.font(.caption.weight(.semibold))
				.foregroundColor(AppConstants.Colours.textSecondary)

			DatePicker(
				"Date",
				selection: $viewModel.selectedDate,
				in: ...Date(),
				displayedComponents: [.date]
			)
			.datePickerStyle(.compact)
			.labelsHidden()
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cornerRadius)
			.overlay(
				RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
					.stroke(AppConstants.Colours.divider, lineWidth: 1)
			)
		}
	}

	private var saveButton: some View {
		PrimaryButton("Save spend", isLoading: viewModel.isSaving) {
			Task {
				let didSave = await viewModel.save()
				if didSave {
					dismiss()
				}
			}
		}
		.opacity(viewModel.canSave ? 1 : 0.6)
		.disabled(viewModel.canSave == false)
	}
}
