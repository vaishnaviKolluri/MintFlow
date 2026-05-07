import Foundation

enum DatabaseError: LocalizedError {

	case connectionFailed(message: String)
	case preparationFailed(message: String)
	case executionFailed(message: String)
	case migrationFailed(message: String)
	case decodingFailed(message: String)
	case notInitialised

	var errorDescription: String? {
		switch self {
		case .connectionFailed(let message):
			return "Could not open the local database: \(message)"
		case .preparationFailed(let message):
			return "Could not prepare statement: \(message)"
		case .executionFailed(let message):
			return "Could not execute statement: \(message)"
		case .migrationFailed(let message):
			return "Could not apply schema migration: \(message)"
		case .decodingFailed(let message):
			return "Could not decode row: \(message)"
		case .notInitialised:
			return "The database has not been initialised."
		}
	}
}
