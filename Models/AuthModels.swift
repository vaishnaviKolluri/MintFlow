// AuthModels.swift
// MintFlow
//
// Authentication request/response models and error types

import Foundation

/// Auth errors with specific messages for each failure type
enum AuthError: LocalizedError, Equatable {
    case invalidEmail
    case weakPassword(reason: String)
    case passwordsDoNotMatch
    case userAlreadyExists
    case invalidCredentials
    case userNotFound
    case emptyFields
    case networkError
    case serverError(message: String)
    case unknownError

    // Specific error messages for each case to show to users
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword(let reason):
            return "Password is too weak: \(reason)"
        case .passwordsDoNotMatch:
            return "Passwords do not match."
        case .userAlreadyExists:
            return "An account with this email already exists."
        case .invalidCredentials:
            return "Invalid email or password."
        case .userNotFound:
            return "No account found with this email."
        case .emptyFields:
            return "Please fill in all required fields."
        case .networkError:
            return "Network error. Please check your connection and try again."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknownError:
            return "An unexpected error occurred. Please try again."
        }
    }
}

struct LoginRequest: Codable, Sendable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable, Sendable {
    let email: String
    let password: String
    let fullName: String
}

struct AuthResponse: Codable, Sendable {
    let user: User
    let token: String
    let expiresAt: Date
}
