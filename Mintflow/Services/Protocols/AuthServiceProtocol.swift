// AuthServiceProtocol.swift
// MintFlow
//

import Foundation

protocol AuthServiceProtocol: Sendable {
    // Registers a new user account. 
    func register(request: RegisterRequest) async throws -> AuthResponse

    // Authenticates an existing user.
    func login(request: LoginRequest) async throws -> AuthResponse

    // Ends the current session
    func logout() async
}
