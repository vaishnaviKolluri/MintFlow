import SwiftUI

struct AmountField: View {

	@Binding var amountText: String
	let placeholder: String

	init(amountText: Binding<String>, placeholder: String = "0.00") {
		self._amountText = amountText
		self.placeholder = placeholder
	}

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 8) {
			Text("$")
				.font(.system(size: 36, weight: .semibold, design: .rounded))
				.foregroundColor(AppConstants.Colours.textSecondary)

			TextField(placeholder, text: $amountText)
				.font(.system(size: 44, weight: .bold, design: .rounded))
				.foregroundColor(AppConstants.Colours.textPrimary)
				.keyboardType(.decimalPad)
				.multilineTextAlignment(.leading)
		}
		.padding(.horizontal, 20)
		.padding(.vertical, 22)
		.frame(maxWidth: .infinity)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cardCornerRadius)
		.overlay(
			RoundedRectangle(cornerRadius: AppConstants.Layout.cardCornerRadius)
				.stroke(AppConstants.Colours.divider, lineWidth: 1)
		)
	}
}
