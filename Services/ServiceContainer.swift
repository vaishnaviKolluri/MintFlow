// ServiceContainer.swift
// MintFlow
//

import Foundation

final class ServiceContainer: @unchecked Sendable {

    static let shared = ServiceContainer()

    let authService: any AuthServiceProtocol
    let validationService: any ValidationServiceProtocol

    private init() {
        self.authService = Self.makeAuthService()
        self.validationService = Self.makeValidationService()
    }

    init(
        authService: any AuthServiceProtocol,
        validationService: any ValidationServiceProtocol
    ) {
        self.authService = authService
        self.validationService = validationService
    }

    private static func makeAuthService() -> any AuthServiceProtocol {
        MockAuthService()
    }

    private static func makeValidationService() -> any ValidationServiceProtocol {
        ValidationService()
    }
}
