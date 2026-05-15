import SwiftUI
import Combine

struct NotificationSettingsView: View {
	
	let user: User
	@StateObject private var notificationManager = NotificationManager.shared
	@StateObject private var viewModel: NotificationSettingsViewModel
	
	init(user: User) {
		self.user = user
		_viewModel = StateObject(wrappedValue: NotificationSettingsViewModel(user: user))
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				headerSection
				
				if !notificationManager.isAuthorized {
					permissionPrompt
				} else {
					dailyReminderSection
					weeklySummarySection
					budgetAlertSection
				}
				
				if viewModel.showError, let error = viewModel.errorMessage {
					ErrorBanner(message: error)
				}
			}
			.padding(.horizontal, AppConstants.Layout.horizontalPadding)
			.padding(.top, 16)
		}
		.background(AppConstants.Colours.background.ignoresSafeArea())
		.task {
			await viewModel.load()
		}
	}
	
	// MARK: - Header
	
	private var headerSection: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Image(systemName: "bell.badge.fill")
					.font(.system(size: 32))
					.foregroundColor(AppConstants.Colours.primary)
				
				Spacer()
			}
			
			Text("Notifications")
				.font(.system(size: 28, weight: .bold, design: .rounded))
				.foregroundColor(AppConstants.Colours.textPrimary)
			
			Text("Stay on top of your spending with smart reminders")
				.font(.subheadline)
				.foregroundColor(AppConstants.Colours.textSecondary)
		}
		.padding(.vertical, 8)
	}
	
	// MARK: - Permission Prompt
	
	private var permissionPrompt: some View {
		VStack(spacing: 16) {
			VStack(spacing: 12) {
				Image(systemName: "bell.slash.fill")
					.font(.system(size: 48))
					.foregroundColor(AppConstants.Colours.textSecondary)
				
				Text("Enable Notifications")
					.font(.headline)
					.foregroundColor(AppConstants.Colours.textPrimary)
				
				Text("Allow MintFlow to send you helpful reminders and spending alerts.")
					.font(.subheadline)
					.foregroundColor(AppConstants.Colours.textSecondary)
					.multilineTextAlignment(.center)
			}
			.padding(.vertical, 24)
			
			PrimaryButton("Enable Notifications") {
				Task {
					await viewModel.requestNotificationPermission()
				}
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity)
		.background(AppConstants.Colours.cardBackground)
		.cornerRadius(AppConstants.Layout.cardCornerRadius)
	}
	
	// MARK: - Daily Reminder
	
	private var dailyReminderSection: some View {
		SettingsCard {
			VStack(spacing: 16) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						Text("Daily Reminder")
							.font(.headline)
							.foregroundColor(AppConstants.Colours.textPrimary)
						
						Text("Get reminded to log your expenses")
							.font(.caption)
							.foregroundColor(AppConstants.Colours.textSecondary)
					}
					
					Spacer()
					
					Toggle("", isOn: $viewModel.preferences.isDailyReminderEnabled)
						.labelsHidden()
						.onChange(of: viewModel.preferences.isDailyReminderEnabled) { _, newValue in
							Task {
								await viewModel.toggleDailyReminder(enabled: newValue)
							}
						}
				}
				
				if viewModel.preferences.isDailyReminderEnabled {
					Divider()
					
					DatePicker(
						"Time",
						selection: $viewModel.dailyReminderTime,
						displayedComponents: .hourAndMinute
					)
					.datePickerStyle(.compact)
					.onChange(of: viewModel.dailyReminderTime) { _, newValue in
						Task {
							await viewModel.updateDailyReminderTime(newValue)
						}
					}
				}
			}
		}
	}
	
	// MARK: - Weekly Summary
	
	private var weeklySummarySection: some View {
		SettingsCard {
			VStack(spacing: 16) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						Text("Weekly Summary")
							.font(.headline)
							.foregroundColor(AppConstants.Colours.textPrimary)
						
						Text("Review your spending insights")
							.font(.caption)
							.foregroundColor(AppConstants.Colours.textSecondary)
					}
					
					Spacer()
					
					Toggle("", isOn: $viewModel.preferences.isWeeklySummaryEnabled)
						.labelsHidden()
						.onChange(of: viewModel.preferences.isWeeklySummaryEnabled) { _, newValue in
							Task {
								await viewModel.toggleWeeklySummary(enabled: newValue)
							}
						}
				}
				
				if viewModel.preferences.isWeeklySummaryEnabled {
					Divider()
					
					Picker("Day", selection: $viewModel.preferences.weeklySummaryWeekday) {
						ForEach(1...7, id: \.self) { weekday in
							Text(weekdayName(for: weekday))
								.tag(weekday)
						}
					}
					.pickerStyle(.menu)
					.onChange(of: viewModel.preferences.weeklySummaryWeekday) { _, _ in
						Task {
							await viewModel.updateWeeklySummary()
						}
					}
					
					DatePicker(
						"Time",
						selection: $viewModel.weeklySummaryTime,
						displayedComponents: .hourAndMinute
					)
					.datePickerStyle(.compact)
					.onChange(of: viewModel.weeklySummaryTime) { _, newValue in
						Task {
							await viewModel.updateWeeklySummaryTime(newValue)
						}
					}
				}
			}
		}
	}
	
	// MARK: - Budget Alert
	
	private var budgetAlertSection: some View {
		SettingsCard {
			VStack(spacing: 16) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						Text("Budget Alerts")
							.font(.headline)
							.foregroundColor(AppConstants.Colours.textPrimary)
						
						Text("Get notified when you reach spending limits")
							.font(.caption)
							.foregroundColor(AppConstants.Colours.textSecondary)
					}
					
					Spacer()
					
					Toggle("", isOn: $viewModel.preferences.isBudgetAlertEnabled)
						.labelsHidden()
						.onChange(of: viewModel.preferences.isBudgetAlertEnabled) { _, _ in
							viewModel.savePref()
						}
				}
				
				if viewModel.preferences.isBudgetAlertEnabled {
					Divider()
					
					VStack(alignment: .leading, spacing: 8) {
						Text("Monthly threshold")
							.font(.caption)
							.foregroundColor(AppConstants.Colours.textSecondary)
						
						HStack {
							Text("$")
								.font(.title3.weight(.semibold))
								.foregroundColor(AppConstants.Colours.textSecondary)
							
							TextField("500", text: $viewModel.budgetThresholdText)
								.keyboardType(.decimalPad)
								.font(.title3.weight(.semibold))
								.foregroundColor(AppConstants.Colours.textPrimary)
								.onChange(of: viewModel.budgetThresholdText) { _, _ in
									viewModel.updateBudgetThreshold()
								}
						}
						.padding(.horizontal, 12)
						.padding(.vertical, 8)
						.background(AppConstants.Colours.background)
						.cornerRadius(8)
					}
				}
			}
		}
	}
	
	// MARK: - Helpers
	
	private func weekdayName(for weekday: Int) -> String {
		let formatter = DateFormatter()
		let weekdaySymbols = formatter.weekdaySymbols ?? []
		guard weekday >= 1, weekday <= weekdaySymbols.count else {
			return "Monday"
		}
		return weekdaySymbols[weekday - 1]
	}
}

// MARK: - Settings Card

private struct SettingsCard<Content: View>: View {
	
	let content: Content
	
	init(@ViewBuilder content: () -> Content) {
		self.content = content()
	}
	
	var body: some View {
		content
			.padding(20)
			.frame(maxWidth: .infinity, alignment: .leading)
			.background(AppConstants.Colours.cardBackground)
			.cornerRadius(AppConstants.Layout.cardCornerRadius)
			.overlay(
				RoundedRectangle(cornerRadius: AppConstants.Layout.cardCornerRadius)
					.stroke(AppConstants.Colours.divider, lineWidth: 1)
			)
	}
}

// MARK: - View Model

@MainActor
final class NotificationSettingsViewModel: ObservableObject {
	
	@Published var preferences: NotificationPreferences
	@Published var dailyReminderTime: Date
	@Published var weeklySummaryTime: Date
	@Published var budgetThresholdText: String
	@Published var showError: Bool = false
	@Published var errorMessage: String?
	
	private let user: User
	private let notificationManager = NotificationManager.shared
	
	init(user: User) {
		self.user = user
		
		// Load preferences first
		let loadedPreferences = NotificationPreferences.load(for: user.id)
		self.preferences = loadedPreferences
		
		// Initialize dates from preferences
		var dailyComponents = DateComponents()
		dailyComponents.hour = loadedPreferences.dailyReminderHour
		dailyComponents.minute = loadedPreferences.dailyReminderMinute
		self.dailyReminderTime = Calendar.current.date(from: dailyComponents) ?? Date()
		
		var weeklyComponents = DateComponents()
		weeklyComponents.hour = loadedPreferences.weeklySummaryHour
		weeklyComponents.minute = loadedPreferences.weeklySummaryMinute
		self.weeklySummaryTime = Calendar.current.date(from: weeklyComponents) ?? Date()
		
		self.budgetThresholdText = String(describing: loadedPreferences.budgetThreshold)
	}
	
	func load() async {
		await notificationManager.updateAuthorizationStatus()
	}
	
	func requestNotificationPermission() async {
		let granted = await notificationManager.requestAuthorization()
		if !granted {
			showError(message: "Please enable notifications in Settings to receive reminders.")
		}
	}
	
	func toggleDailyReminder(enabled: Bool) async {
		if enabled {
			do {
				try await notificationManager.scheduleDailyReminder(
					at: preferences.dailyReminderHour,
					minute: preferences.dailyReminderMinute
				)
			} catch {
				showError(message: "Failed to schedule daily reminder: \(error.localizedDescription)")
				preferences.isDailyReminderEnabled = false
			}
		} else {
			notificationManager.cancelDailyReminder()
		}
		savePref()
	}
	
	func updateDailyReminderTime(_ date: Date) async {
		let components = Calendar.current.dateComponents([.hour, .minute], from: date)
		preferences.dailyReminderHour = components.hour ?? 20
		preferences.dailyReminderMinute = components.minute ?? 0
		
		if preferences.isDailyReminderEnabled {
			do {
				try await notificationManager.scheduleDailyReminder(
					at: preferences.dailyReminderHour,
					minute: preferences.dailyReminderMinute
				)
			} catch {
				showError(message: "Failed to update daily reminder: \(error.localizedDescription)")
			}
		}
		savePref()
	}
	
	func toggleWeeklySummary(enabled: Bool) async {
		if enabled {
			do {
				try await notificationManager.scheduleWeeklySummary(
					on: preferences.weeklySummaryWeekday,
					hour: preferences.weeklySummaryHour,
					minute: preferences.weeklySummaryMinute
				)
			} catch {
				showError(message: "Failed to schedule weekly summary: \(error.localizedDescription)")
				preferences.isWeeklySummaryEnabled = false
			}
		} else {
			notificationManager.cancelWeeklySummary()
		}
		savePref()
	}
	
	func updateWeeklySummary() async {
		if preferences.isWeeklySummaryEnabled {
			do {
				try await notificationManager.scheduleWeeklySummary(
					on: preferences.weeklySummaryWeekday,
					hour: preferences.weeklySummaryHour,
					minute: preferences.weeklySummaryMinute
				)
			} catch {
				showError(message: "Failed to update weekly summary: \(error.localizedDescription)")
			}
		}
		savePref()
	}
	
	func updateWeeklySummaryTime(_ date: Date) async {
		let components = Calendar.current.dateComponents([.hour, .minute], from: date)
		preferences.weeklySummaryHour = components.hour ?? 9
		preferences.weeklySummaryMinute = components.minute ?? 0
		
		await updateWeeklySummary()
	}
	
	func updateBudgetThreshold() {
		if let value = Decimal(string: budgetThresholdText) {
			preferences.budgetThreshold = value
			savePref()
		}
	}
	
	func savePref() {
		preferences.save(for: user.id)
	}
	
	private func showError(message: String) {
		errorMessage = message
		showError = true
		
		Task {
			try? await Task.sleep(for: .seconds(3))
			showError = false
		}
	}
}
