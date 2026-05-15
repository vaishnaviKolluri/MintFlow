import Foundation

protocol SpendRepositoryProtocol: Sendable {

	func insert(spend: Spend) async throws
	func update(spend: Spend) async throws
	func delete(identifier: UUID) async throws

	func fetchAll(for userIdentifier: UUID) async throws -> [Spend]
	func fetchRecent(for userIdentifier: UUID, limit: Int) async throws -> [Spend]
	func fetchInRange(
		userIdentifier: UUID,
		startingAt rangeStart: Date,
		endingAt rangeEnd: Date
	) async throws -> [Spend]

	func count(for userIdentifier: UUID) async throws -> Int
}
