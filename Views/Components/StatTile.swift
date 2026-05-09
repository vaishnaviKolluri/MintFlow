import SwiftUI

struct StatTile: View {

	let title: String
	let value: String
	let caption: String?
	let iconName: String
	let accentColour: Color

	init(
		title: String,
		value: String,
		caption: String? = nil,
		iconName: String,
		accentColour: Color = AppConstants.Colours.primary
	) {
		self.title = title
		self.value = value
		self.caption = caption
		self.iconName = iconName
		self.accentColour = accentColour
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack(spacing: 8) {
				Image(systemName: iconName)
					.font(.subheadline.weight(.semibold))
					.foregroundColor(accentColour)
					.frame(width: 28, height: 28)
					.background(accentColour.opacity(0.15))
					.clipShape(Circle())

				Text(title)
					.font(.caption)
					.foregroundColor(AppConstants.Colours.textSecondary)
				Spacer()
			}

			Text(value)
				.font(.system(size: 22, weight: .bold, design: .rounded))
				.foregroundColor(AppConstants.Colours.textPrimary)
				.lineLimit(1)
				.minimumScaleFactor(0.7)

			if let caption {
				Text(caption)
					.font(.caption2)
					.foregroundColor(AppConstants.Colours.textSecondary)
			}
		}
		.padding(16)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cardCornerRadius)
		.shadow(color: .black.opacity(0.05), radius: 6, y: 2)
	}
}
