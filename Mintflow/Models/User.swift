// User.swift
// MintFlow
//
// Core user model

import Foundation
/// Immutable user model that works with SwiftUI lists, JSON APIs, and async code.
struct User: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let email: String
    let fullName: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        email: String,
        fullName: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.createdAt = createdAt
    }
}
