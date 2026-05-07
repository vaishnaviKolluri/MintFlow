import Foundation
import SQLite3

private let sqliteTransientDestructor = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

enum DatabaseValue: Sendable {
	case text(String)
	case integer(Int64)
	case real(Double)
	case null
}

struct DatabaseRow: Sendable {

	let values: [DatabaseValue]

	func text(at index: Int) -> String {
		guard index < values.count, case .text(let value) = values[index] else { return "" }
		return value
	}

	func integer(at index: Int) -> Int64 {
		guard index < values.count else { return 0 }
		switch values[index] {
		case .integer(let value):	return value
		case .real(let value):		return Int64(value)
		case .text(let value):		return Int64(value) ?? 0
		case .null:					return 0
		}
	}

	func real(at index: Int) -> Double {
		guard index < values.count else { return 0 }
		switch values[index] {
		case .real(let value):		return value
		case .integer(let value):	return Double(value)
		case .text(let value):		return Double(value) ?? 0
		case .null:					return 0
		}
	}
}

actor Database {

	private var connection: OpaquePointer?
	private let filePath: String

	init(filePath: String) throws {
		self.filePath = filePath

		try Self.ensureContainerExists(for: filePath)

		var handle: OpaquePointer?
		let openResult = sqlite3_open(filePath, &handle)
		guard openResult == SQLITE_OK, let opened = handle else {
			let message = handle.flatMap { String(cString: sqlite3_errmsg($0)) } ?? "code \(openResult)"
			sqlite3_close(handle)
			throw DatabaseError.connectionFailed(message: message)
		}

		self.connection = opened

		sqlite3_exec(opened, "PRAGMA journal_mode = WAL;", nil, nil, nil)
		sqlite3_exec(opened, "PRAGMA foreign_keys = ON;", nil, nil, nil)
	}

	deinit {
		if let connection {
			sqlite3_close(connection)
		}
	}

	var storagePath: String { filePath }

	func execute(sql: String, bindings: [DatabaseValue] = []) throws {
		try withPreparedStatement(sql: sql) { handle in
			try bind(values: bindings, to: handle)
			let stepResult = sqlite3_step(handle)
			guard stepResult == SQLITE_DONE || stepResult == SQLITE_ROW else {
				throw DatabaseError.executionFailed(message: lastErrorMessage())
			}
		}
	}

	func executeBatch(sql: String) throws {
		guard let connection else { throw DatabaseError.notInitialised }

		var errorPointer: UnsafeMutablePointer<CChar>?
		let result = sqlite3_exec(connection, sql, nil, nil, &errorPointer)
		if result != SQLITE_OK {
			let message = errorPointer.flatMap { String(cString: $0) } ?? "code \(result)"
			sqlite3_free(errorPointer)
			throw DatabaseError.executionFailed(message: message)
		}
	}

	func query(sql: String, bindings: [DatabaseValue] = []) throws -> [DatabaseRow] {
		var rows: [DatabaseRow] = []

		try withPreparedStatement(sql: sql) { handle in
			try bind(values: bindings, to: handle)

			while sqlite3_step(handle) == SQLITE_ROW {
				let columnCount = sqlite3_column_count(handle)
				var rowValues: [DatabaseValue] = []
				rowValues.reserveCapacity(Int(columnCount))

				for columnIndex in 0..<columnCount {
					rowValues.append(extractValue(handle: handle, columnIndex: columnIndex))
				}
				rows.append(DatabaseRow(values: rowValues))
			}
		}

		return rows
	}

	func queryFirst(sql: String, bindings: [DatabaseValue] = []) throws -> DatabaseRow? {
		try query(sql: sql, bindings: bindings).first
	}

	func transaction<T>(_ body: () throws -> T) throws -> T {
		try executeBatch(sql: "BEGIN TRANSACTION;")
		do {
			let result = try body()
			try executeBatch(sql: "COMMIT;")
			return result
		} catch {
			try? executeBatch(sql: "ROLLBACK;")
			throw error
		}
	}

	private func withPreparedStatement(sql: String, body: (OpaquePointer) throws -> Void) throws {
		guard let connection else { throw DatabaseError.notInitialised }

		var handle: OpaquePointer?
		let prepareResult = sqlite3_prepare_v2(connection, sql, -1, &handle, nil)
		guard prepareResult == SQLITE_OK, let preparedHandle = handle else {
			throw DatabaseError.preparationFailed(message: lastErrorMessage())
		}
		defer { sqlite3_finalize(preparedHandle) }

		try body(preparedHandle)
	}

	private func bind(values: [DatabaseValue], to handle: OpaquePointer) throws {
		for (offset, value) in values.enumerated() {
			let parameterIndex = Int32(offset + 1)
			let bindResult: Int32

			switch value {
			case .text(let text):
				bindResult = sqlite3_bind_text(handle, parameterIndex, text, -1, sqliteTransientDestructor)
			case .integer(let integer):
				bindResult = sqlite3_bind_int64(handle, parameterIndex, integer)
			case .real(let real):
				bindResult = sqlite3_bind_double(handle, parameterIndex, real)
			case .null:
				bindResult = sqlite3_bind_null(handle, parameterIndex)
			}

			guard bindResult == SQLITE_OK else {
				throw DatabaseError.executionFailed(message: lastErrorMessage())
			}
		}
	}

	private func extractValue(handle: OpaquePointer, columnIndex: Int32) -> DatabaseValue {
		let columnType = sqlite3_column_type(handle, columnIndex)

		switch columnType {
		case SQLITE_INTEGER:
			return .integer(sqlite3_column_int64(handle, columnIndex))
		case SQLITE_FLOAT:
			return .real(sqlite3_column_double(handle, columnIndex))
		case SQLITE_TEXT:
			guard let cString = sqlite3_column_text(handle, columnIndex) else { return .null }
			return .text(String(cString: cString))
		case SQLITE_NULL:
			return .null
		default:
			return .null
		}
	}

	private func lastErrorMessage() -> String {
		guard let connection, let cString = sqlite3_errmsg(connection) else {
			return "Unknown SQLite error"
		}
		return String(cString: cString)
	}

	private static func ensureContainerExists(for filePath: String) throws {
		let directory = (filePath as NSString).deletingLastPathComponent
		guard !directory.isEmpty else { return }

		let url = URL(fileURLWithPath: directory, isDirectory: true)
		if !FileManager.default.fileExists(atPath: url.path) {
			try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		}
	}
}

extension Database {

	static func defaultStoreURL() throws -> URL {
		let supportRoot = try FileManager.default.url(
			for: .applicationSupportDirectory,
			in: .userDomainMask,
			appropriateFor: nil,
			create: true
		)
		let appFolder = supportRoot.appendingPathComponent(AppConstants.appName, isDirectory: true)
		if !FileManager.default.fileExists(atPath: appFolder.path) {
			try FileManager.default.createDirectory(at: appFolder, withIntermediateDirectories: true)
		}
		return appFolder.appendingPathComponent("mintflow.sqlite", isDirectory: false)
	}
}
