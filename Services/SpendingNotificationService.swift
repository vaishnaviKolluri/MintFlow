import Foundation

@MainActor
final class SpendingNotificationService {
	
	static let shared = SpendingNotificationService()
	
	private let notificationManager = NotificationManager.shared
	
	private init() {}
	
	/// Check if user has exceeded budget threshold and send notification if needed
	func checkBudgetThreshold(for userId: UUID, currentTotal: Decimal) async {
		let preferences = NotificationPreferences.load(for: userId)
		
		guard preferences.isBudgetAlertEnabled,
			  notificationManager.isAuthorized else {
			return
		}
		
		// Only send alert if they've reached or exceeded the threshold
		guard currentTotal >= preferences.budgetThreshold else {
			return
		}
		
		// Check if we've already sent an alert this month
		let lastAlertKey = "last-budget-alert-\(userId.uuidString)"
		let now = Date()
		let calendar = Calendar.current
		
		if let lastAlertDate = UserDefaults.standard.object(forKey: lastAlertKey) as? Date {
			// If we already sent an alert this month, don't send another
			if calendar.isDate(lastAlertDate, equalTo: now, toGranularity: .month) {
				return
			}
		}
		
		// Send the alert
		do {
			try await notificationManager.scheduleSpendingAlert(
				amount: currentTotal,
				category: nil
			)
			
			// Record that we sent the alert
			UserDefaults.standard.set(now, forKey: lastAlertKey)
		} catch {
			print("Failed to send budget alert: \(error)")
		}
	}
	
	/// Check category spending and send notification if approaching a limit
	func checkCategorySpending(for userId: UUID, category: String, amount: Decimal, threshold: Decimal) async {
		let preferences = NotificationPreferences.load(for: userId)
		
		guard preferences.isBudgetAlertEnabled,
			  notificationManager.isAuthorized,
			  amount >= threshold else {
			return
		}
		
		// Check if we've already sent an alert for this category this month
		let lastAlertKey = "last-category-alert-\(userId.uuidString)-\(category)"
		let now = Date()
		let calendar = Calendar.current
		
		if let lastAlertDate = UserDefaults.standard.object(forKey: lastAlertKey) as? Date {
			if calendar.isDate(lastAlertDate, equalTo: now, toGranularity: .month) {
				return
			}
		}
		
		// Send the alert
		do {
			try await notificationManager.scheduleSpendingAlert(
				amount: amount,
				category: category
			)
			
			// Record that we sent the alert
			UserDefaults.standard.set(now, forKey: lastAlertKey)
		} catch {
			print("Failed to send category alert: \(error)")
		}
	}
}
