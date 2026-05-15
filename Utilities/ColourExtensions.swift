import SwiftUI

extension Color {

	init(hex: String) {
		let trimmed = hex
			.trimmingCharacters(in: .whitespacesAndNewlines)
			.replacingOccurrences(of: "#", with: "")

		var hexValue: UInt64 = 0
		Scanner(string: trimmed).scanHexInt64(&hexValue)

		let red: Double
		let green: Double
		let blue: Double
		let alpha: Double

		switch trimmed.count {
		case 6:
			red		= Double((hexValue & 0xFF0000) >> 16) / 255.0
			green	= Double((hexValue & 0x00FF00) >> 8) / 255.0
			blue	= Double(hexValue & 0x0000FF) / 255.0
			alpha	= 1.0
		case 8:
			red		= Double((hexValue & 0xFF000000) >> 24) / 255.0
			green	= Double((hexValue & 0x00FF0000) >> 16) / 255.0
			blue	= Double((hexValue & 0x0000FF00) >> 8) / 255.0
			alpha	= Double(hexValue & 0x000000FF) / 255.0
		default:
			red = 0; green = 0; blue = 0; alpha = 1
		}

		self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
	}
}
