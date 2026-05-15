// LoginViewModel.swift
// MintFlow
//

import Foundation

@MainActor
final class LoginViewModel: ObservableObject {

    @Published var email: String = ""
    @Published var password: String = ""

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

    // Validates inputs then attempts login.
    func login() async -> AuthResponse? {
        errorMessage = nil

        if case .failure(let error) = validationService.validateEmail(email) {
            errorMessage = error.localizedDescription
            return nil
        }
        guard !password.isEmpty else {
            errorMessage = AuthError.emptyFields.localizedDescription
            return nil
        }

        // Backend call
        isLoading = true
        defer { isLoading = false }

        do {
            let request = LoginRequest(email: email, password: password)
            let response = try await authService.login(request: request)
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
