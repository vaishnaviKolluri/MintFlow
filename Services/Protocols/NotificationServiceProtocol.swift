// NotificationServiceProtocol.swift
// MintFlow
//
// Permission, scheduling, and cancellation of local notifications.
// LocalNotificationService wraps UNUserNotificationCenter; tests can
// substitute a mock conforming to this protocol.

import Foundation

/// Authorization state for local notifications.
enum NotificationAuthStatus: Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
}

/// A scheduled notification request the app cares about.
struct NotificationItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let body: String
    let fireDate: Date
    let category: NotificationCategory

    init(
        id: String = UUID().uuidString,
        title: String,
        body: String,
        fireDate: Date,
        category: NotificationCategory
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.fireDate = fireDate
        self.category = category
    }
}

enum NotificationCategory: String, Codable, CaseIterable, Sendable, Identifiable {
    case billReminder
    case budgetAlert
    case savingsMilestone
    case general

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .billReminder:     return "Bill Reminder"
        case .budgetAlert:      return "Budget Alert"
        case .savingsMilestone: return "Savings Milestone"
        case .general:          return "General"
        }
    }

    var icon: String {
        switch self {
        case .billReminder:     return "calendar.badge.clock"
        case .budgetAlert:      return "exclamationmark.triangle.fill"
        case .savingsMilestone: return "flag.checkered"
        case .general:          return "bell.fill"
        }
    }
}

protocol NotificationServiceProtocol: Sendable {
    /// Current authorization status.
    func authorizationStatus() async -> NotificationAuthStatus

    /// Prompt the user for permission. Returns the granted state.
    func requestAuthorization() async -> Bool

    /// Schedule a notification at the given fire date.
    /// Returns the system identifier (matches `item.id`) on success.
    @discardableResult
    func schedule(_ item: NotificationItem) async throws -> String

    /// Schedule a recurring notification (e.g. monthly bill reminder).
    /// `interval` in seconds; iOS minimum for repeating is 60.
    @discardableResult
    func scheduleRepeating(
        _ item: NotificationItem,
        interval: TimeInterval
    ) async throws -> String

    /// Cancel by identifier.
    func cancel(id: String) async

    /// Cancel everything pending.
    func cancelAll() async

    /// All currently pending notifications.
    func pending() async -> [NotificationItem]
}

/// Errors the notification layer can surface to ViewModels.
enum NotificationError: LocalizedError {
    case permissionDenied
    case schedulingFailed(String)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Notifications are disabled. Enable them in Settings to receive alerts."
        case .schedulingFailed(let reason):
            return "Couldn't schedule notification: \(reason)"
        }
    }
}
