// MockTransactionService.swift
// MintFlow
//
// In-memory transaction store. Seeded with realistic data so the
// Analytics screen has something to show on first launch.

import Foundation

actor MockTransactionService: TransactionServiceProtocol {

    private var store: [UUID: [Transaction]] = [:]
    private var seeded: Set<UUID> = []

    func fetchTransactions(for userId: UUID) async -> [Transaction] {
        seedIfNeeded(for: userId)
        return (store[userId] ?? []).sorted { $0.date > $1.date }
    }

    func addTransaction(_ transaction: Transaction) async {
        store[transaction.userId, default: []].append(transaction)
    }

    func deleteTransaction(id: UUID, userId: UUID) async {
        store[userId]?.removeAll { $0.id == id }
    }

    func fetchTransactions(
        for userId: UUID,
        from start: Date,
        to end: Date
    ) async -> [Transaction] {
        seedIfNeeded(for: userId)
        return (store[userId] ?? [])
            .filter { $0.date >= start && $0.date <= end }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Seed data

    private func seedIfNeeded(for userId: UUID) {
        guard !seeded.contains(userId) else { return }
        seeded.insert(userId)

        let cal = Calendar.current
        let now = Date()
        func daysAgo(_ n: Int) -> Date {
            cal.date(byAdding: .day, value: -n, to: now) ?? now
        }

        let sample: [Transaction] = [
            // This month
            Transaction(userId: userId, amount: 2_500.00, category: .income,
                        type: .income, note: "Monthly salary", date: daysAgo(2)),
            Transaction(userId: userId, amount: 45.99, category: .food,
                        type: .expense, note: "Grocery shopping", date: daysAgo(1)),
            Transaction(userId: userId, amount: 12.50, category: .transport,
                        type: .expense, note: "Uber ride", date: daysAgo(3)),
            Transaction(userId: userId, amount: 89.99, category: .shopping,
                        type: .expense, note: "New headphones", date: daysAgo(5)),
            Transaction(userId: userId, amount: 35.00, category: .entertainment,
                        type: .expense, note: "Movie tickets", date: daysAgo(7)),
            Transaction(userId: userId, amount: 110.40, category: .utilities,
                        type: .expense, note: "Electricity bill", date: daysAgo(10)),
            Transaction(userId: userId, amount: 64.20, category: .food,
                        type: .expense, note: "Dinner out", date: daysAgo(12)),
            Transaction(userId: userId, amount: 28.00, category: .health,
                        type: .expense, note: "Pharmacy", date: daysAgo(15)),
            // Last month
            Transaction(userId: userId, amount: 2_500.00, category: .income,
                        type: .income, note: "Monthly salary", date: daysAgo(33)),
            Transaction(userId: userId, amount: 220.00, category: .shopping,
                        type: .expense, note: "Clothing", date: daysAgo(35)),
            Transaction(userId: userId, amount: 145.50, category: .food,
                        type: .expense, note: "Groceries", date: daysAgo(40)),
            Transaction(userId: userId, amount: 56.00, category: .transport,
                        type: .expense, note: "Fuel", date: daysAgo(42)),
            // Two months ago
            Transaction(userId: userId, amount: 2_500.00, category: .income,
                        type: .income, note: "Monthly salary", date: daysAgo(63)),
            Transaction(userId: userId, amount: 320.00, category: .entertainment,
                        type: .expense, note: "Concert tickets", date: daysAgo(70)),
            Transaction(userId: userId, amount: 180.00, category: .food,
                        type: .expense, note: "Groceries", date: daysAgo(75)),
        ]

        store[userId] = sample
    }
}
