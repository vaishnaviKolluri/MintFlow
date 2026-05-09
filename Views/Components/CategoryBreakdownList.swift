import SwiftUI

struct CategoryBreakdownList: View {

	let breakdown: [CategoryBreakdown]

	var body: some View {
		VStack(spacing: 14) {
			ForEach(breakdown) { entry in
				CategoryBreakdownRow(entry: entry)
			}
		}
		.padding(16)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cardCornerRadius)
		.shadow(color: .black.opacity(0.05), radius: 6, y: 2)
	}
}

private struct CategoryBreakdownRow: View {

	let entry: CategoryBreakdown

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack(spacing: 10) {
				Image(systemName: entry.category.icon)
					.font(.caption.weight(.semibold))
					.foregroundColor(AppConstants.Colours.primary)
					.frame(width: 28, height: 28)
					.background(AppConstants.Colours.primarySoft)
					.clipShape(Circle())

				Text(entry.category.displayName)
					.font(.subheadline.weight(.medium))
					.foregroundColor(AppConstants.Colours.textPrimary)

				Spacer()

				Text(CurrencyFormatter.format(entry.total))
					.font(.subheadline.weight(.semibold))
					.foregroundColor(AppConstants.Colours.textPrimary)
					.monospacedDigit()
			}

			GeometryReader { proxy in
				ZStack(alignment: .leading) {
					Capsule()
						.fill(AppConstants.Colours.divider)
						.frame(height: 6)
					Capsule()
						.fill(AppConstants.Colours.primary)
						.frame(width: max(6, proxy.size.width * entry.proportion), height: 6)
				}
			}
			.frame(height: 6)
		}
	}
}
