// ValidationService.swift
// MintFlow
//

import Foundation

final class ValidationService: ValidationServiceProtocol {

    func validateEmail(_ email: String) -> Result<Void, AuthError> {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            return .failure(.emptyFields)
        }

        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        guard trimmed.range(of: pattern, options: .regularExpression) != nil else {
            return .failure(.invalidEmail)
        }

        return .success(())
    }

    func validatePassword(_ password: String) -> Result<Void, AuthError> {
        guard !password.isEmpty else {
            return .failure(.emptyFields)
        }
        guard password.count >= 8 else {
            return .failure(.weakPassword(reason: "Must be at least 8 characters."))
        }
        guard password.range(of: #"[A-Z]"#, options: .regularExpression) != nil else {
            return .failure(.weakPassword(reason: "Must contain at least one uppercase letter."))
        }
        guard password.range(of: #"[a-z]"#, options: .regularExpression) != nil else {
            return .failure(.weakPassword(reason: "Must contain at least one lowercase letter."))
        }
        guard password.range(of: #"[0-9]"#, options: .regularExpression) != nil else {
            return .failure(.weakPassword(reason: "Must contain at least one number."))
        }

        return .success(())
    }

    func validateName(_ name: String) -> Result<Void, AuthError> {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return .failure(.emptyFields)
        }
        return .success(())
    }
}
