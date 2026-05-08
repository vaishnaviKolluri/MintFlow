import Foundation

final class ServiceContainer: @unchecked Sendable {

	static let shared = ServiceContainer()

	let authService: any AuthServiceProtocol
	let validationService: any ValidationServiceProtocol
	let database: Database
	let spendRepository: any SpendRepositoryProtocol
	let spendingService: any SpendingServiceProtocol
	let databaseSeeder: DatabaseSeeder

	private init() {
		let database = Self.makeDatabase()
		let repository = SpendRepository(database: database)

		self.authService = Self.makeAuthService()
		self.validationService = Self.makeValidationService()
		self.database = database
		self.spendRepository = repository
		self.spendingService = SpendingService(repository: repository)
		self.databaseSeeder = DatabaseSeeder(repository: repository)
	}

	init(
		authService: any AuthServiceProtocol,
		validationService: any ValidationServiceProtocol,
		database: Database,
		spendRepository: any SpendRepositoryProtocol,
		spendingService: any SpendingServiceProtocol,
		databaseSeeder: DatabaseSeeder
	) {
		self.authService = authService
		self.validationService = validationService
		self.database = database
		self.spendRepository = spendRepository
		self.spendingService = spendingService
		self.databaseSeeder = databaseSeeder
	}

	func bootstrapDatabase() async {
		do {
			try await DatabaseSchema.migrate(database: database)
		} catch {
			print("Database migration failed: \(error.localizedDescription)")
		}
	}

	func seedSampleData(for userIdentifier: UUID) async {
		do {
			try await databaseSeeder.seedIfEmpty(for: userIdentifier)
		} catch {
			print("Database seeding failed: \(error.localizedDescription)")
		}
	}

	private static func makeAuthService() -> any AuthServiceProtocol {
		MockAuthService()
	}

	private static func makeValidationService() -> any ValidationServiceProtocol {
		ValidationService()
	}

	private static func makeDatabase() -> Database {
		do {
			let storeURL = try Database.defaultStoreURL()
			return try Database(filePath: storeURL.path)
		} catch {
			fatalError("Could not initialise local database: \(error.localizedDescription)")
		}
	}
}
