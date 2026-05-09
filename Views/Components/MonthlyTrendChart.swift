import SwiftUI
import Charts

struct MonthlyTrendChart: View {

	let monthlyTotals: [MonthlyTotal]

	var body: some View {
		Chart {
			ForEach(monthlyTotals) { entry in
				BarMark(
					x: .value("Month", entry.label),
					y: .value("Total", NSDecimalNumber(decimal: entry.total).doubleValue)
				)
				.foregroundStyle(
					LinearGradient(
						colors: [AppConstants.Colours.primary, AppConstants.Colours.primaryDark],
						startPoint: .top,
						endPoint: .bottom
					)
				)
			}
		}
		.chartYAxis {
			AxisMarks(position: .leading) { value in
				AxisGridLine()
					.foregroundStyle(AppConstants.Colours.divider)
				AxisValueLabel {
					if let amount = value.as(Double.self) {
						Text(CurrencyFormatter.format(amount))
							.font(.caption2)
							.foregroundColor(AppConstants.Colours.textSecondary)
					}
				}
			}
		}
		.chartXAxis {
			AxisMarks { _ in
				AxisValueLabel()
					.font(.caption2)
					.foregroundStyle(AppConstants.Colours.textSecondary)
			}
		}
		.frame(height: 180)
	}
}
