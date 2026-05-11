// TransactionServiceProtocol.swift
// MintFlow
//
// Abstracts how transactions are stored and queried.
// Swap MockTransactionService for a real backend (Firestore, REST, CoreData)
// without touching ViewModels.

import Foundation

protocol TransactionServiceProtocol: Sendable {
    /// All transactions for a user, newest first.
    func fetchTransactions(for userId: UUID) async -> [Transaction]

    /// Persist a new transaction.
    func addTransaction(_ transaction: Transaction) async

    /// Remove a transaction by id.
    func deleteTransaction(id: UUID, userId: UUID) async

    /// Transactions within a date range (inclusive), newest first.
    func fetchTransactions(
        for userId: UUID,
        from start: Date,
        to end: Date
    ) async -> [Transaction]
}
