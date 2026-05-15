import Foundation

struct DatabaseSeeder {

	let repository: SpendRepositoryProtocol

	init(repository: SpendRepositoryProtocol) {
		self.repository = repository
	}

	func seedIfEmpty(for userIdentifier: UUID) async throws {
		let existingCount = try await repository.count(for: userIdentifier)
		guard existingCount == 0 else { return }

		try await seed(for: userIdentifier)
	}

	func seed(for userIdentifier: UUID) async throws {
		let sampleSpends = Self.makeSampleSpends(for: userIdentifier)
		for spend in sampleSpends {
			try await repository.insert(spend: spend)
		}
	}

	func resetAndReseed(for userIdentifier: UUID) async throws {
		let existing = try await repository.fetchAll(for: userIdentifier)
		for spend in existing {
			try await repository.delete(identifier: spend.identifier)
		}
		try await seed(for: userIdentifier)
	}

	private static func makeSampleSpends(for userIdentifier: UUID) -> [Spend] {
		let calendar = Calendar.current
		let now = Date()

		let blueprints: [(daysAgo: Int, amount: Decimal, category: Category, summary: String)] = [
			(0,		8.50,	.food,			"Flat white and toastie"),
			(0,		42.10,	.transport,		"Weekly Opal top-up"),
			(1,		112.40,	.shopping,		"Cotton on basics"),
			(1,		18.75,	.food,			"Sushi Train lunch"),
			(2,		65.20,	.utilities,		"Mobile plan recharge"),
			(2,		24.00,	.entertainment,	"Cinema ticket"),
			(3,		96.30,	.food,			"Coles weekly shop"),
			(4,		55.00,	.health,		"Pharmacy supplies"),
			(5,		15.40,	.transport,		"Uber to the city"),
			(6,		220.00,	.utilities,		"Electricity bill"),
			(8,		38.90,	.food,			"Friday night pizza"),
			(10,	19.99,	.entertainment,	"Streaming subscription"),
			(12,	84.50,	.shopping,		"Bunnings hardware"),
			(14,	12.30,	.food,			"Bakery breakfast"),
			(16,	150.00,	.health,		"GP appointment"),
			(20,	72.40,	.education,		"Online course module"),
			(24,	44.20,	.food,			"Date night dinner"),
			(28,	305.00,	.shopping,		"New runners"),
			(34,	21.00,	.transport,		"Petrol top-up"),
			(40,	58.00,	.food,			"Birthday brunch"),
			(46,	260.00,	.utilities,		"Internet bill"),
			(52,	33.50,	.entertainment,	"Concert tickets"),
			(58,	88.20,	.shopping,		"Homewares"),
			(63,	125.00,	.health,		"Gym membership")
		]

		return blueprints.compactMap { blueprint in
			guard let spentAt = calendar.date(byAdding: .day, value: -blueprint.daysAgo, to: now) else {
				return nil
			}
			return Spend(
				userIdentifier: userIdentifier,
				amount: blueprint.amount,
				category: blueprint.category,
				summary: blueprint.summary,
				spentAt: spentAt,
				createdAt: spentAt
			)
		}
	}
}
