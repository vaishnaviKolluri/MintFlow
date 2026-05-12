// Transaction.swift
// MintFlow
//
// financial transaction record linked to a user and category

import Foundation

enum TransactionType: String, Codable, CaseIterable, Sendable {
    case income
    case expense
}

/// Use Decimal for accuracy + immutable to prevent accidental changes to transactions
struct Transaction: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let userId: UUID
    let amount: Decimal
    let category: Category
    let type: TransactionType
    let note: String
    let date: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        amount: Decimal,
        category: Category,
        type: TransactionType,
        note: String = "",
        date: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.amount = amount
        self.category = category
        self.type = type
        self.note = note
        self.date = date
    }
}
