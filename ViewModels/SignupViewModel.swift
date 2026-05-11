// SignupViewModel.swift
// MintFlow
//

import Foundation
import Combine

@MainActor
final class SignupViewModel: ObservableObject {

    @Published var fullName: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""

    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

        private let authService: any AuthServiceProtocol
    private let validationService: any ValidationServiceProtocol

    init(
        authService: any AuthServiceProtocol = ServiceContainer.shared.authService,
        validationService: any ValidationServiceProtocol = ServiceContainer.shared.validationService
    ) {
        self.authService = authService
        self.validationService = validationService
    }

    // Validates all fields then attempts registration.
    func register() async -> AuthResponse? {
        errorMessage = nil

        if case .failure(let error) = validationService.validateName(fullName) {
            errorMessage = error.localizedDescription
            return nil
        }
        if case .failure(let error) = validationService.validateEmail(email) {
            errorMessage = error.localizedDescription
            return nil
        }
        if case .failure(let error) = validationService.validatePassword(password) {
            errorMessage = error.localizedDescription
            return nil
        }
        guard password == confirmPassword else {
            errorMessage = AuthError.passwordsDoNotMatch.localizedDescription
            return nil
        }

        // Backend call
        isLoading = true
        defer { isLoading = false }

        do {
            let request = RegisterRequest(
                email: email,
                password: password,
                fullName: fullName
            )
            let response = try await authService.register(request: request)
            return response
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
            return nil
        } catch {
            errorMessage = AuthError.unknownError.localizedDescription
            return nil
        }
    }

    func clearError() {
        errorMessage = nil
    }
}
