// ServiceContainer.swift
// MintFlow
//

import Foundation

final class ServiceContainer: @unchecked Sendable {

    static let shared = ServiceContainer()

    let authService: any AuthServiceProtocol
    let validationService: any ValidationServiceProtocol
    let transactionService: any TransactionServiceProtocol
    let notificationService: any NotificationServiceProtocol

    private init() {
        self.authService = Self.makeAuthService()
        self.validationService = Self.makeValidationService()
        self.transactionService = Self.makeTransactionService()
        self.notificationService = Self.makeNotificationService()
    }

    init(
        authService: any AuthServiceProtocol,
        validationService: any ValidationServiceProtocol,
        transactionService: any TransactionServiceProtocol,
        notificationService: any NotificationServiceProtocol
    ) {
        self.authService = authService
        self.validationService = validationService
        self.transactionService = transactionService
        self.notificationService = notificationService
    }

    private static func makeAuthService() -> any AuthServiceProtocol {
        MockAuthService()
    }

    private static func makeValidationService() -> any ValidationServiceProtocol {
        ValidationService()
    }

    private static func makeTransactionService() -> any TransactionServiceProtocol {
        MockTransactionService()
    }

    private static func makeNotificationService() -> any NotificationServiceProtocol {
        LocalNotificationService()
    }
}
