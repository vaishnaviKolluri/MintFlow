import Foundation

struct Currency: Identifiable, Equatable {
	let id = UUID()
	let code: String
	let name: String
	let symbol: String
	let flag: String
}

// MARK: - Codable Conformance

extension Currency: Codable {
	enum CodingKeys: String, CodingKey {
		case code, name, symbol, flag
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		code = try container.decode(String.self, forKey: .code)
		name = try container.decode(String.self, forKey: .name)
		symbol = try container.decode(String.self, forKey: .symbol)
		flag = try container.decode(String.self, forKey: .flag)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(code, forKey: .code)
		try container.encode(name, forKey: .name)
		try container.encode(symbol, forKey: .symbol)
		try container.encode(flag, forKey: .flag)
	}
}
