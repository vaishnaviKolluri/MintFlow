// NotificationsViewModel.swift
// MintFlow
//
// Drives the Notifications screen: permission state, creating bill
// reminders / budget alerts, and listing pending items.

import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {

    // MARK: - Published state

    @Published private(set) var authStatus: NotificationAuthStatus = .notDetermined
    @Published private(set) var pendingItems: [NotificationItem] = []
    @Published private(set) var isWorking = false
    @Published var errorMessage: String?
    @Published var infoMessage: String?

    // Form fields for creating a bill reminder
    @Published var billTitle: String = ""
    @Published var billAmount: String = ""
    @Published var billDate: Date = Calendar.current.date(
        byAdding: .day, value: 3, to: Date()
    ) ?? Date()
    @Published var billRepeats: Bool = false

    // Form fields for a budget alert
    @Published var budgetCategory: Category = .food
    @Published var budgetThreshold: String = "80"

    // MARK: - Dependencies

    private let notificationService: any NotificationServiceProtocol

    init(
        notificationService: any NotificationServiceProtocol =
            ServiceContainer.shared.notificationService
    ) {
        self.notificationService = notificationService
    }

    // MARK: - Lifecycle

    func load() async {
        authStatus = await notificationService.authorizationStatus()
        pendingItems = await notificationService.pending()
    }

    func requestPermission() async {
        isWorking = true
        defer { isWorking = false }

        let granted = await notificationService.requestAuthorization()
        authStatus = await notificationService.authorizationStatus()

        if granted {
            infoMessage = "Notifications enabled."
        } else {
            errorMessage = "Permission denied. You can enable it in Settings."
        }
    }

    // MARK: - Bill reminders

    func scheduleBillReminder() async {
        clearMessages()

        let trimmedTitle = billTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a bill name."
            return
        }
        guard billDate > Date() else {
            errorMessage = "Pick a date in the future."
            return
        }

        let amountText = billAmount.trimmingCharacters(in: .whitespacesAndNewlines)
        let amountSuffix = amountText.isEmpty ? "" : " — $\(amountText) due"

        let item = NotificationItem(
            title: "Bill Reminder: \(trimmedTitle)",
            body: "Don't forget your \(trimmedTitle.lowercased()) payment\(amountSuffix).",
            fireDate: billDate,
            category: .billReminder
        )

        await runScheduling { [weak self] in
            guard let self else { return }
            if self.billRepeats {
                // ~30 day repeat. iOS only supports time-interval repeats,
                // so this is an approximation of "monthly".
                let monthInSeconds: TimeInterval = 60 * 60 * 24 * 30
                try await self.notificationService.scheduleRepeating(
                    item, interval: monthInSeconds
                )
            } else {
                try await self.notificationService.schedule(item)
            }
            self.infoMessage = "Reminder scheduled."
            self.resetBillForm()
        }
    }

    private func resetBillForm() {
        billTitle = ""
        billAmount = ""
        billRepeats = false
        billDate = Calendar.current.date(
            byAdding: .day, value: 3, to: Date()
        ) ?? Date()
    }

    // MARK: - Budget alerts

    func scheduleBudgetAlert() async {
        clearMessages()

        guard let pct = Int(budgetThreshold), (1...100).contains(pct) else {
            errorMessage = "Threshold must be between 1 and 100."
            return
        }

        // Demo behaviour: fire in 10 seconds so the user can see it work.
        // In a production app this would be triggered by the alerts engine
        // when actual spending crosses the threshold.
        let fire = Date().addingTimeInterval(10)
        let item = NotificationItem(
            title: "\(budgetCategory.displayName) Budget Alert",
            body: "You've used \(pct)% of your \(budgetCategory.displayName.lowercased()) budget.",
            fireDate: fire,
            category: .budgetAlert
        )

        await runScheduling { [weak self] in
            guard let self else { return }
            try await self.notificationService.schedule(item)
            self.infoMessage = "Budget alert scheduled (fires in ~10s)."
        }
    }

    // MARK: - Pending list management

    func cancel(_ item: NotificationItem) async {
        await notificationService.cancel(id: item.id)
        pendingItems = await notificationService.pending()
        infoMessage = "Cancelled \(item.title)."
    }

    func cancelAll() async {
        await notificationService.cancelAll()
        pendingItems = await notificationService.pending()
        infoMessage = "Cleared all reminders."
    }

    // MARK: - Helpers

    private func runScheduling(_ work: @escaping () async throws -> Void) async {
        isWorking = true
        defer { isWorking = false }

        do {
            try await work()
            pendingItems = await notificationService.pending()
            authStatus = await notificationService.authorizationStatus()
        } catch let err as NotificationError {
            errorMessage = err.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func clearMessages() {
        errorMessage = nil
        infoMessage = nil
    }

    // MARK: - Display helpers

    var permissionBannerText: String? {
        switch authStatus {
        case .authorized, .provisional: return nil
        case .notDetermined:
            return "Enable notifications to get bill reminders and budget alerts."
        case .denied:
            return "Notifications are disabled. Re-enable them in iOS Settings."
        }
    }

    func formatted(date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
