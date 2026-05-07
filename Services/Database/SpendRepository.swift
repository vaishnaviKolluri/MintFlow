import Foundation

final class SpendRepository: SpendRepositoryProtocol {

	private let database: Database

	init(database: Database) {
		self.database = database
	}

	func insert(spend: Spend) async throws {
		let sql = """
			INSERT INTO spends (
				identifier,
				userIdentifier,
				amountCents,
				category,
				summary,
				spentAt,
				createdAt
			)
			VALUES (?, ?, ?, ?, ?, ?, ?);
			"""

		try await database.execute(sql: sql, bindings: bindings(for: spend))
	}

	func update(spend: Spend) async throws {
		let sql = """
			UPDATE spends
			SET amountCents = ?,
				category = ?,
				summary = ?,
				spentAt = ?
			WHERE identifier = ?;
			"""

		try await database.execute(
			sql: sql,
			bindings: [
				.integer(Self.cents(from: spend.amount)),
				.text(spend.category.rawValue),
				.text(spend.summary),
				.integer(Int64(spend.spentAt.timeIntervalSince1970)),
				.text(spend.identifier.uuidString)
			]
		)
	}

	func delete(identifier: UUID) async throws {
		try await database.execute(
			sql: "DELETE FROM spends WHERE identifier = ?;",
			bindings: [.text(identifier.uuidString)]
		)
	}

	func fetchAll(for userIdentifier: UUID) async throws -> [Spend] {
		let sql = """
			SELECT identifier, userIdentifier, amountCents, category, summary, spentAt, createdAt
			FROM spends
			WHERE userIdentifier = ?
			ORDER BY spentAt DESC;
			"""

		let rows = try await database.query(
			sql: sql,
			bindings: [.text(userIdentifier.uuidString)]
		)
		return rows.compactMap(Self.spend(from:))
	}

	func fetchRecent(for userIdentifier: UUID, limit: Int) async throws -> [Spend] {
		let sql = """
			SELECT identifier, userIdentifier, amountCents, category, summary, spentAt, createdAt
			FROM spends
			WHERE userIdentifier = ?
			ORDER BY spentAt DESC
			LIMIT ?;
			"""

		let rows = try await database.query(
			sql: sql,
			bindings: [
				.text(userIdentifier.uuidString),
				.integer(Int64(limit))
			]
		)
		return rows.compactMap(Self.spend(from:))
	}

	func fetchInRange(
		userIdentifier: UUID,
		startingAt rangeStart: Date,
		endingAt rangeEnd: Date
	) async throws -> [Spend] {
		let sql = """
			SELECT identifier, userIdentifier, amountCents, category, summary, spentAt, createdAt
			FROM spends
			WHERE userIdentifier = ? AND spentAt >= ? AND spentAt <= ?
			ORDER BY spentAt DESC;
			"""

		let rows = try await database.query(
			sql: sql,
			bindings: [
				.text(userIdentifier.uuidString),
				.integer(Int64(rangeStart.timeIntervalSince1970)),
				.integer(Int64(rangeEnd.timeIntervalSince1970))
			]
		)
		return rows.compactMap(Self.spend(from:))
	}

	func count(for userIdentifier: UUID) async throws -> Int {
		let row = try await database.queryFirst(
			sql: "SELECT COUNT(*) FROM spends WHERE userIdentifier = ?;",
			bindings: [.text(userIdentifier.uuidString)]
		)
		return Int(row?.integer(at: 0) ?? 0)
	}

	private func bindings(for spend: Spend) -> [DatabaseValue] {
		[
			.text(spend.identifier.uuidString),
			.text(spend.userIdentifier.uuidString),
			.integer(Self.cents(from: spend.amount)),
			.text(spend.category.rawValue),
			.text(spend.summary),
			.integer(Int64(spend.spentAt.timeIntervalSince1970)),
			.integer(Int64(spend.createdAt.timeIntervalSince1970))
		]
	}

	private static func cents(from amount: Decimal) -> Int64 {
		let multiplied = amount * Decimal(100)
		var rounded = Decimal()
		var source = multiplied
		NSDecimalRound(&rounded, &source, 0, .plain)
		return NSDecimalNumber(decimal: rounded).int64Value
	}

	private static func amount(fromCents cents: Int64) -> Decimal {
		Decimal(cents) / Decimal(100)
	}

	private static func spend(from row: DatabaseRow) -> Spend? {
		guard let identifier = UUID(uuidString: row.text(at: 0)),
			  let userIdentifier = UUID(uuidString: row.text(at: 1)) else {
			return nil
		}
		guard let category = Category(rawValue: row.text(at: 3)) else {
			return nil
		}

		return Spend(
			identifier: identifier,
			userIdentifier: userIdentifier,
			amount: amount(fromCents: row.integer(at: 2)),
			category: category,
			summary: row.text(at: 4),
			spentAt: Date(timeIntervalSince1970: TimeInterval(row.integer(at: 5))),
			createdAt: Date(timeIntervalSince1970: TimeInterval(row.integer(at: 6)))
		)
	}
}
