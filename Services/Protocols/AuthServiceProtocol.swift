// AuthServiceProtocol.swift
// MintFlow
//

import Foundation

protocol AuthServiceProtocol: Sendable {
    // Registers a new user account. 
    func register(request: RegisterRequest) async throws -> AuthResponse

    // Authenticates an existing user.
    func login(request: LoginRequest) async throws -> AuthResponse
    
    // Updates user information
    func updateUser(userId: UUID, fullName: String, email: String) async throws -> User

    // Ends the current session
    func logout() async
}
