// NotificationPreferences.swift
// MintFlow
//
// User preferences for notifications

import Foundation

struct NotificationPreferences: Codable, Equatable {
	
	// Daily reminder settings
	var isDailyReminderEnabled: Bool
	var dailyReminderHour: Int
	var dailyReminderMinute: Int
	
	// Weekly summary settings
	var isWeeklySummaryEnabled: Bool
	var weeklySummaryWeekday: Int // 1 = Sunday, 2 = Monday, etc.
	var weeklySummaryHour: Int
	var weeklySummaryMinute: Int
	
	// Budget alerts
	var isBudgetAlertEnabled: Bool
	var budgetThreshold: Decimal
	
	static let `default` = NotificationPreferences(
		isDailyReminderEnabled: false,
		dailyReminderHour: 20, // 8 PM
		dailyReminderMinute: 0,
		isWeeklySummaryEnabled: false,
		weeklySummaryWeekday: 2, // Monday
		weeklySummaryHour: 9, // 9 AM
		weeklySummaryMinute: 0,
		isBudgetAlertEnabled: false,
		budgetThreshold: 500
	)
}

// MARK: - Persistence

extension NotificationPreferences {
	
	private static let userDefaultsKey = "com.mintflow.notification-preferences"
	
	static func load(for userId: UUID) -> NotificationPreferences {
		guard let data = UserDefaults.standard.data(forKey: "\(userDefaultsKey).\(userId.uuidString)"),
			  let preferences = try? JSONDecoder().decode(NotificationPreferences.self, from: data) else {
			return .default
		}
		return preferences
	}
	
	func save(for userId: UUID) {
		guard let data = try? JSONEncoder().encode(self) else { return }
		UserDefaults.standard.set(data, forKey: "\(NotificationPreferences.userDefaultsKey).\(userId.uuidString)")
	}
	
	static func delete(for userId: UUID) {
		UserDefaults.standard.removeObject(forKey: "\(userDefaultsKey).\(userId.uuidString)")
	}
}

// MARK: - Weekday Helper

extension NotificationPreferences {
	
	var weeklySummaryWeekdayName: String {
		let formatter = DateFormatter()
		let weekdaySymbols = formatter.weekdaySymbols ?? []
		guard weeklySummaryWeekday >= 1, weeklySummaryWeekday <= weekdaySymbols.count else {
			return "Monday"
		}
		return weekdaySymbols[weeklySummaryWeekday - 1]
	}
	
	var dailyReminderTimeFormatted: String {
		formatTime(hour: dailyReminderHour, minute: dailyReminderMinute)
	}
	
	var weeklySummaryTimeFormatted: String {
		formatTime(hour: weeklySummaryHour, minute: weeklySummaryMinute)
	}
	
	private func formatTime(hour: Int, minute: Int) -> String {
		let formatter = DateFormatter()
		formatter.timeStyle = .short
		
		var components = DateComponents()
		components.hour = hour
		components.minute = minute
		
		if let date = Calendar.current.date(from: components) {
			return formatter.string(from: date)
		}
		
		return "\(hour):\(String(format: "%02d", minute))"
	}
}
