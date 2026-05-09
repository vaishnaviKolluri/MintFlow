import SwiftUI

struct CategoryChip: View {

	let iconName: String?
	let label: String
	let isSelected: Bool
	let onTap: () -> Void

	init(iconName: String?, label: String, isSelected: Bool, onTap: @escaping () -> Void) {
		self.iconName = iconName
		self.label = label
		self.isSelected = isSelected
		self.onTap = onTap
	}

	init(category: Category, isSelected: Bool, onTap: @escaping () -> Void) {
		self.iconName = category.icon
		self.label = category.displayName
		self.isSelected = isSelected
		self.onTap = onTap
	}

	var body: some View {
		Button(action: onTap) {
			HStack(spacing: 8) {
				if let iconName {
					Image(systemName: iconName)
						.font(.caption.weight(.semibold))
				}
				Text(label)
					.font(.caption.weight(.medium))
			}
			.padding(.horizontal, 14)
			.padding(.vertical, 9)
			.foregroundColor(foregroundColour)
			.background(backgroundColour)
			.overlay(
				RoundedRectangle(cornerRadius: 999)
					.stroke(borderColour, lineWidth: 1)
			)
			.cornerRadius(999)
		}
		.buttonStyle(.plain)
	}

	private var foregroundColour: Color {
		isSelected ? .white : AppConstants.Colours.textPrimary
	}

	private var backgroundColour: Color {
		isSelected ? AppConstants.Colours.primary : AppConstants.Colours.cardBackground
	}

	private var borderColour: Color {
		isSelected ? AppConstants.Colours.primary : AppConstants.Colours.divider
	}
}

struct CategoryChipsRow: View {

	let categories: [Category]
	@Binding var selectedCategory: Category?

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(spacing: 8) {
				CategoryChip(
					iconName: nil,
					label: "All",
					isSelected: selectedCategory == nil,
					onTap: { selectedCategory = nil }
				)

				ForEach(categories) { category in
					CategoryChip(
						category: category,
						isSelected: selectedCategory == category,
						onTap: {
							selectedCategory = selectedCategory == category ? nil : category
						}
					)
				}
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
		}
	}
}
