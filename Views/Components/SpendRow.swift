import SwiftUI

struct SpendRow: View {

	let spend: Spend
	let showsRelativeTime: Bool

	init(spend: Spend, showsRelativeTime: Bool = false) {
		self.spend = spend
		self.showsRelativeTime = showsRelativeTime
	}

	var body: some View {
		HStack(spacing: 14) {
			Image(systemName: spend.category.icon)
				.font(.subheadline.weight(.semibold))
				.foregroundColor(AppConstants.Colours.primary)
				.frame(width: 40, height: 40)
				.background(AppConstants.Colours.primarySoft)
				.clipShape(Circle())

			VStack(alignment: .leading, spacing: 3) {
				Text(spend.summary)
					.font(.subheadline.weight(.medium))
					.foregroundColor(AppConstants.Colours.textPrimary)
					.lineLimit(1)

				HStack(spacing: 6) {
					Text(spend.category.displayName)
					if showsRelativeTime {
						Text("·")
						Text(spend.spentAt.formattedShortDay())
					}
				}
				.font(.caption)
				.foregroundColor(AppConstants.Colours.textSecondary)
			}

			Spacer()

			Text("-\(CurrencyFormatter.format(spend.amount))")
				.font(.subheadline.weight(.semibold))
				.foregroundColor(AppConstants.Colours.expense)
				.monospacedDigit()
		}
		.padding(.vertical, 12)
		.padding(.horizontal, 16)
		.background(AppConstants.Colours.cardBackground)
		.contentShape(Rectangle())
	}
}
