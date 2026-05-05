// MockAuthService.swift
// MintFlow
//
// To use a real backend, swap this in ServiceContainer 

import Foundation
import CryptoKit

private struct StoredCredential: Sendable {
    let user: User
    let passwordHash: String
}

actor MockAuthService: AuthServiceProtocol {

    private var userStore: [String: StoredCredential] = []

    func register(request: RegisterRequest) async throws -> AuthResponse {
        try await simulateNetworkDelay()

        let email = request.email
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Duplicate check
        guard userStore[email] == nil else {
            throw AuthError.userAlreadyExists
        }

        let user = User(email: email, fullName: request.fullName)
        let hash = hashPassword(request.password)

        userStore[email] = StoredCredential(user: user, passwordHash: hash)

        return AuthResponse(
            user: user,
            token: generateToken(),
            expiresAt: Date().addingTimeInterval(3600)
        )
    }

    func login(request: LoginRequest) async throws -> AuthResponse {
        try await simulateNetworkDelay()

        let email = request.email
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let stored = userStore[email] else {
            throw AuthError.invalidCredentials
        }

        guard hashPassword(request.password) == stored.passwordHash else {
            throw AuthError.invalidCredentials
        }

        return AuthResponse(
            user: stored.user,
            token: generateToken(),
            expiresAt: Date().addingTimeInterval(3600)
        )
    }

    func logout() async {
        // 
    }


    /// Simulates network delay
    private func simulateNetworkDelay() async throws {
        let delay = Double.random(in: 0.5...1.5)
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }

    /// SHA-256 hash 
    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let digest = SHA256.hash(data: data)
        return digest.compactMap { String(format: "%02x", $0) }.joined()
    }

    private func generateToken() -> String {
        UUID().uuidString
    }
}
