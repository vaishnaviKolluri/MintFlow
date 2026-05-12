// ValidationServiceProtocol.swift
// MintFlow
//

import Foundation

protocol ValidationServiceProtocol {
    // Validates an email address format
    func validateEmail(_ email: String) -> Result<Void, AuthError>

    // Validates password strength requirements
    func validatePassword(_ password: String) -> Result<Void, AuthError>

    // Validates that a name field is non-empty
    func validateName(_ name: String) -> Result<Void, AuthError>
}
