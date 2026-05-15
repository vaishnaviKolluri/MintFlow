import UserNotifications
import Foundation
import Combine

@MainActor
final class NotificationManager: NSObject, ObservableObject {
	
	static let shared = NotificationManager()
	
	@Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
	@Published private(set) var isAuthorized: Bool = false
	
	private let center = UNUserNotificationCenter.current()
	
	private override init() {
		super.init()
		center.delegate = self
		Task {
			await updateAuthorizationStatus()
		}
	}
	
	// MARK: - Authorization
	
	func requestAuthorization() async -> Bool {
		do {
			let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
			await updateAuthorizationStatus()
			return granted
		} catch {
			print("Error requesting notification authorization: \(error)")
			return false
		}
	}
	
	func updateAuthorizationStatus() async {
		let settings = await center.notificationSettings()
		authorizationStatus = settings.authorizationStatus
		isAuthorized = settings.authorizationStatus == .authorized
	}
	
	// MARK: - Daily Spending Reminder
	
	/// Schedule a daily reminder to log spending
	func scheduleDailyReminder(at hour: Int, minute: Int) async throws {
		guard isAuthorized else {
			throw NotificationError.notAuthorized
		}
		
		// Remove existing daily reminder
		center.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.dailyReminder])
		
		let content = UNMutableNotificationContent()
		content.title = "Track Your Spending"
		content.body = "Don't forget to log today's expenses in MintFlow!"
		content.sound = .default
		content.categoryIdentifier = NotificationCategory.reminder
		
		var dateComponents = DateComponents()
		dateComponents.hour = hour
		dateComponents.minute = minute
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		let request = UNNotificationRequest(
			identifier: NotificationIdentifier.dailyReminder,
			content: content,
			trigger: trigger
		)
		
		try await center.add(request)
	}
	
	func cancelDailyReminder() {
		center.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.dailyReminder])
	}
	
	// MARK: - Budget Alerts
	
	/// Schedule a notification when spending approaches a certain threshold
	func scheduleSpendingAlert(amount: Decimal, category: String?) async throws {
		guard isAuthorized else {
			throw NotificationError.notAuthorized
		}
		
		let content = UNMutableNotificationContent()
		content.title = "Spending Alert"
		
		if let category = category {
			content.body = "You've spent \(formatCurrency(amount)) on \(category) this month."
		} else {
			content.body = "You've spent \(formatCurrency(amount)) this month."
		}
		
		content.sound = .default
		content.categoryIdentifier = NotificationCategory.budgetAlert
		
		// Trigger immediately
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
		let identifier = category.map { "\(NotificationIdentifier.budgetAlert)_\($0)" } ?? NotificationIdentifier.budgetAlert
		
		let request = UNNotificationRequest(
			identifier: identifier,
			content: content,
			trigger: trigger
		)
		
		try await center.add(request)
	}
	
	// MARK: - Weekly Summary
	
	/// Schedule a weekly summary notification
	func scheduleWeeklySummary(on weekday: Int, hour: Int, minute: Int) async throws {
		guard isAuthorized else {
			throw NotificationError.notAuthorized
		}
		
		// Remove existing weekly summary
		center.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.weeklySummary])
		
		let content = UNMutableNotificationContent()
		content.title = "Weekly Spending Summary"
		content.body = "Check out your spending insights for this week!"
		content.sound = .default
		content.categoryIdentifier = NotificationCategory.summary
		
		var dateComponents = DateComponents()
		dateComponents.weekday = weekday // 1 = Sunday, 2 = Monday, etc.
		dateComponents.hour = hour
		dateComponents.minute = minute
		
		let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
		let request = UNNotificationRequest(
			identifier: NotificationIdentifier.weeklySummary,
			content: content,
			trigger: trigger
		)
		
		try await center.add(request)
	}
	
	func cancelWeeklySummary() {
		center.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.weeklySummary])
	}
	
	// MARK: - Utility
	
	func cancelAllNotifications() {
		center.removeAllPendingNotificationRequests()
	}
	
	func getPendingNotifications() async -> [UNNotificationRequest] {
		await center.pendingNotificationRequests()
	}
	
	private func formatCurrency(_ amount: Decimal) -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.currencyCode = AppConstants.currencyCode
		formatter.locale = Locale(identifier: AppConstants.currencyLocaleIdentifier)
		return formatter.string(from: amount as NSDecimalNumber) ?? "$\(amount)"
	}
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
	
	// Handle notifications when app is in foreground
	nonisolated func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		willPresent notification: UNNotification
	) async -> UNNotificationPresentationOptions {
		// Show notification even when app is in foreground
		return [.banner, .sound, .badge]
	}
	
	// Handle notification tap
	nonisolated func userNotificationCenter(
		_ center: UNUserNotificationCenter,
		didReceive response: UNNotificationResponse
	) async {
		let categoryId = response.notification.request.content.categoryIdentifier
		
		// You can add custom actions here based on the notification category
		print("Notification tapped: \(categoryId)")
		
		// Navigate to appropriate screen based on notification type
		// This would require posting to NotificationCenter or using a deep link handler
	}
}

// MARK: - Supporting Types

enum NotificationError: LocalizedError {
	case notAuthorized
	case schedulingFailed
	
	var errorDescription: String? {
		switch self {
		case .notAuthorized:
			return "Notification permissions are not granted. Please enable them in Settings."
		case .schedulingFailed:
			return "Failed to schedule notification."
		}
	}
}

enum NotificationIdentifier {
	static let dailyReminder = "com.mintflow.notification.daily-reminder"
	static let weeklySummary = "com.mintflow.notification.weekly-summary"
	static let budgetAlert = "com.mintflow.notification.budget-alert"
}

enum NotificationCategory {
	static let reminder = "REMINDER"
	static let budgetAlert = "BUDGET_ALERT"
	static let summary = "SUMMARY"
}
