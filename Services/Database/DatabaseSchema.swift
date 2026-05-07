import Foundation

enum DatabaseSchema {

	static let currentVersion: Int64 = 1

	static let createMigrationsTable = """
		CREATE TABLE IF NOT EXISTS schemaMigrations (
			versionNumber INTEGER PRIMARY KEY NOT NULL,
			appliedAt INTEGER NOT NULL
		);
		"""

	static let createSpendsTable = """
		CREATE TABLE IF NOT EXISTS spends (
			identifier TEXT PRIMARY KEY NOT NULL,
			userIdentifier TEXT NOT NULL,
			amountCents INTEGER NOT NULL,
			category TEXT NOT NULL,
			summary TEXT NOT NULL,
			spentAt INTEGER NOT NULL,
			createdAt INTEGER NOT NULL
		);
		"""

	static let createSpendsIndexUserDate = """
		CREATE INDEX IF NOT EXISTS spendsUserDateIndex ON spends (userIdentifier, spentAt DESC);
		"""

	static let createSpendsIndexCategory = """
		CREATE INDEX IF NOT EXISTS spendsCategoryIndex ON spends (category);
		"""

	static func bootstrapStatements() -> [String] {
		[
			createMigrationsTable,
			createSpendsTable,
			createSpendsIndexUserDate,
			createSpendsIndexCategory
		]
	}

	static func migrate(database: Database) async throws {
		for statement in bootstrapStatements() {
			try await database.execute(sql: statement)
		}

		let row = try await database.queryFirst(
			sql: "SELECT versionNumber FROM schemaMigrations ORDER BY versionNumber DESC LIMIT 1;"
		)
		let installedVersion = row?.integer(at: 0) ?? 0

		if installedVersion < currentVersion {
			try await database.execute(
				sql: "INSERT INTO schemaMigrations (versionNumber, appliedAt) VALUES (?, ?);",
				bindings: [
					.integer(currentVersion),
					.integer(Int64(Date().timeIntervalSince1970))
				]
			)
		}
	}
}
