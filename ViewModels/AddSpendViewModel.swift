import Foundation
import SwiftUI

@MainActor
final class AddSpendViewModel: ObservableObject {

	@Published var amountText: String = ""
	@Published var summaryText: String = ""
	@Published var selectedCategory: Category = .food
	@Published var selectedDate: Date = Date()

	@Published private(set) var isSaving: Bool = false
	@Published private(set) var errorMessage: String?

	let user: User
	private let spendingService: any SpendingServiceProtocol
	private let onSavedSpend: (Spend) -> Void

	init(
		user: User,
		spendingService: any SpendingServiceProtocol = ServiceContainer.shared.spendingService,
		onSavedSpend: @escaping (Spend) -> Void = { _ in }
	) {
		self.user = user
		self.spendingService = spendingService
		self.onSavedSpend = onSavedSpend
	}

	var canSave: Bool {
		parsedAmount != nil && trimmedSummary.isEmpty == false && isSaving == false
	}

	var availableCategories: [Category] {
		Category.allCases.filter { $0 != .income }
	}

	func save() async -> Bool {
		errorMessage = nil

		guard let amount = parsedAmount, amount > 0 else {
			errorMessage = "Please enter a valid amount greater than zero."
			return false
		}

		guard trimmedSummary.isEmpty == false else {
			errorMessage = "Please add a short description for this spend."
			return false
		}

		isSaving = true
		defer { isSaving = false }

		do {
			let spend = try await spendingService.recordSpend(
				userIdentifier: user.id,
				amount: amount,
				category: selectedCategory,
				summary: trimmedSummary,
				spentAt: selectedDate
			)
			onSavedSpend(spend)
			return true
		} catch {
			errorMessage = error.localizedDescription
			return false
		}
	}

	private var trimmedSummary: String {
		summaryText.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	private var parsedAmount: Decimal? {
		let cleaned = amountText
			.replacingOccurrences(of: "$", with: "")
			.replacingOccurrences(of: ",", with: "")
			.trimmingCharacters(in: .whitespacesAndNewlines)
		guard cleaned.isEmpty == false else { return nil }
		return Decimal(string: cleaned)
	}
}
