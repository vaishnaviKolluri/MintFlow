// HomeViewModel.swift
// MintFlow
//

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    let user: User

    @Published private(set) var totalBalance: Decimal = 2_450.75
    @Published private(set) var monthlySpending: Decimal = 1_230.50
    @Published private(set) var savingsGoalProgress: Double = 0.65

    let recentTransactions: [Transaction]

    init(user: User) {
        self.user = user

        // Sample data for UI demonstration
        // In the real app these come from TransactionService.
        self.recentTransactions = [
            Transaction(
                userId: user.id, amount: 45.99,
                category: .food, type: .expense,
                note: "Grocery shopping"
            ),
            Transaction(
                userId: user.id, amount: 2_500.00,
                category: .income, type: .income,
                note: "Monthly salary"
            ),
            Transaction(
                userId: user.id, amount: 12.50,
                category: .transport, type: .expense,
                note: "Uber ride"
            ),
            Transaction(
                userId: user.id, amount: 89.99,
                category: .shopping, type: .expense,
                note: "New headphones"
            ),
            Transaction(
                userId: user.id, amount: 35.00,
                category: .entertainment, type: .expense,
                note: "Movie tickets"
            ),
        ]
    }

    var firstName: String {
        user.fullName.components(separatedBy: " ").first ?? user.fullName
    }

    var formattedBalance: String {
        formatCurrency(totalBalance)
    }

    var formattedSpending: String {
        formatCurrency(monthlySpending)
    }

    private func formatCurrency(_ value: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "AUD"
        return formatter.string(from: value as NSDecimalNumber) ?? "$\(value)"
    }
}
