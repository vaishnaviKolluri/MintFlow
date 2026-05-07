import Foundation

struct Spend: Identifiable, Codable, Equatable, Sendable, Hashable {

	let identifier: UUID
	let userIdentifier: UUID
	let amount: Decimal
	let category: Category
	let summary: String
	let spentAt: Date
	let createdAt: Date

	var id: UUID { identifier }

	init(
		identifier: UUID = UUID(),
		userIdentifier: UUID,
		amount: Decimal,
		category: Category,
		summary: String,
		spentAt: Date = Date(),
		createdAt: Date = Date()
	) {
		self.identifier = identifier
		self.userIdentifier = userIdentifier
		self.amount = amount
		self.category = category
		self.summary = summary
		self.spentAt = spentAt
		self.createdAt = createdAt
	}
}

extension Spend {

	func with(
		amount: Decimal? = nil,
		category: Category? = nil,
		summary: String? = nil,
		spentAt: Date? = nil
	) -> Spend {
		Spend(
			identifier: identifier,
			userIdentifier: userIdentifier,
			amount: amount ?? self.amount,
			category: category ?? self.category,
			summary: summary ?? self.summary,
			spentAt: spentAt ?? self.spentAt,
			createdAt: createdAt
		)
	}
}
