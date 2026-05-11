// LocalNotificationService.swift
// MintFlow
//
// Production implementation of NotificationServiceProtocol that
// wraps UNUserNotificationCenter for scheduling local notifications.
//
// Important: the app must include the "Push Notifications" capability
// only if you want REMOTE notifications. Local notifications work
// out-of-the-box with no entitlement.

import Foundation
import UserNotifications

final class LocalNotificationService: NotificationServiceProtocol {

    private let center = UNUserNotificationCenter.current()

    func authorizationStatus() async -> NotificationAuthStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: return .notDetermined
        case .denied:        return .denied
        case .authorized, .ephemeral: return .authorized
        case .provisional:   return .provisional
        @unknown default:    return .notDetermined
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(
                options: [.alert, .badge, .sound]
            )
        } catch {
            return false
        }
    }

    @discardableResult
    func schedule(_ item: NotificationItem) async throws -> String {
        try await ensureAuthorized()

        let content = makeContent(for: item)
        let interval = max(1, item.fireDate.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: interval,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: item.id,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            return item.id
        } catch {
            throw NotificationError.schedulingFailed(error.localizedDescription)
        }
    }

    @discardableResult
    func scheduleRepeating(
        _ item: NotificationItem,
        interval: TimeInterval
    ) async throws -> String {
        try await ensureAuthorized()

        let content = makeContent(for: item)
        // iOS requires a minimum 60s interval for repeating triggers.
        let safeInterval = max(60, interval)
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: safeInterval,
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: item.id,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
            return item.id
        } catch {
            throw NotificationError.schedulingFailed(error.localizedDescription)
        }
    }

    func cancel(id: String) async {
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelAll() async {
        center.removeAllPendingNotificationRequests()
    }

    func pending() async -> [NotificationItem] {
        let requests = await center.pendingNotificationRequests()
        return requests.compactMap { req in
            guard
                let trigger = req.trigger as? UNTimeIntervalNotificationTrigger,
                let fireDate = trigger.nextTriggerDate()
            else { return nil }

            let categoryRaw = req.content.userInfo["category"] as? String
            let category = NotificationCategory(rawValue: categoryRaw ?? "")
                ?? .general

            return NotificationItem(
                id: req.identifier,
                title: req.content.title,
                body: req.content.body,
                fireDate: fireDate,
                category: category
            )
        }
        .sorted { $0.fireDate < $1.fireDate }
    }

    // MARK: - Helpers

    private func ensureAuthorized() async throws {
        let status = await authorizationStatus()
        switch status {
        case .authorized, .provisional:
            return
        case .notDetermined:
            let granted = await requestAuthorization()
            if !granted { throw NotificationError.permissionDenied }
        case .denied:
            throw NotificationError.permissionDenied
        }
    }

    private func makeContent(for item: NotificationItem) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = item.body
        content.sound = .default
        content.userInfo = ["category": item.category.rawValue]
        return content
    }
}

// MARK: - Mock for tests / SwiftUI previews

actor MockNotificationService: NotificationServiceProtocol {

    private var status: NotificationAuthStatus = .authorized
    private var scheduled: [String: NotificationItem] = [:]

    func setStatus(_ status: NotificationAuthStatus) { self.status = status }

    func authorizationStatus() async -> NotificationAuthStatus { status }

    func requestAuthorization() async -> Bool {
        status = .authorized
        return true
    }

    @discardableResult
    func schedule(_ item: NotificationItem) async throws -> String {
        guard status == .authorized || status == .provisional else {
            throw NotificationError.permissionDenied
        }
        scheduled[item.id] = item
        return item.id
    }

    @discardableResult
    func scheduleRepeating(
        _ item: NotificationItem,
        interval: TimeInterval
    ) async throws -> String {
        try await schedule(item)
    }

    func cancel(id: String) async {
        scheduled.removeValue(forKey: id)
    }

    func cancelAll() async {
        scheduled.removeAll()
    }

    func pending() async -> [NotificationItem] {
        Array(scheduled.values).sorted { $0.fireDate < $1.fireDate }
    }
}
