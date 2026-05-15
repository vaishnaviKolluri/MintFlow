// Budget.swift
// MintFlow
//

import Foundation

/// Spending categories for transactions and budgets
enum Category: String, Codable, CaseIterable, Identifiable, Sendable {
    case food
    case transport
    case entertainment
    case utilities
    case shopping
    case health
    case education
    case savings
    case income
    case other

    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    /// Icons for the categories
    var icon: String {
        switch self {
        case .food:          return "fork.knife"
        case .transport:     return "car.fill"
        case .entertainment: return "gamecontroller.fill"
        case .utilities:     return "bolt.fill"
        case .shopping:      return "bag.fill"
        case .health:        return "heart.fill"
        case .education:     return "book.fill"
        case .savings:       return "banknote.fill"
        case .income:        return "dollarsign.circle.fill"
        case .other:         return "ellipsis.circle.fill"
        }
    }
}

/// How often the budget resets (weekly, monthly, yearly)
enum BudgetPeriod: String, Codable, CaseIterable, Sendable {
    case weekly
    case monthly
    case yearly

    var displayName: String {
        rawValue.capitalized
    }
}

/// Spending limit for a category over a time period
struct Budget: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let userId: UUID
    let category: Category
    let limit: Decimal
    let period: BudgetPeriod
    let startDate: Date

    init(
        id: UUID = UUID(),
        userId: UUID,
        category: Category,
        limit: Decimal,
        period: BudgetPeriod,
        startDate: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.category = category
        self.limit = limit
        self.period = period
        self.startDate = startDate
    }
}
