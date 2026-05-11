// NotificationsView.swift
// MintFlow
//
// Bill reminders, budget alerts, and pending notification list.

import SwiftUI

struct NotificationsView: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = NotificationsViewModel()

    var body: some View {
        ZStack {
            AppConstants.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    headerTitle

                    if let banner = viewModel.permissionBannerText {
                        permissionBanner(text: banner)
                    }

                    if let info = viewModel.infoMessage {
                        infoBanner(text: info)
                    }

                    if let err = viewModel.errorMessage {
                        ErrorBanner(message: err)
                    }

                    SectionHeader(title: "Bill Reminder")
                    billReminderCard

                    SectionHeader(title: "Budget Alert")
                    budgetAlertCard

                    SectionHeader(title: "Scheduled")
                    pendingCard

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                .padding(.top, 16)
            }
        }
        .overlay(alignment: .topLeading) {
            BackButton { appViewModel.navigate(to: .home) }
        }
        .task { await viewModel.load() }
    }

    // MARK: - Header

    private var headerTitle: some View {
        Text("Notifications")
            .font(.headline.weight(.semibold))
            .foregroundColor(AppConstants.Colors.textPrimary)
            .padding(.top, 4)
    }

    // MARK: - Banners

    private func permissionBanner(text: String) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "bell.badge")
                    .foregroundColor(AppConstants.Colors.primary)
                Text(text)
                    .font(.footnote)
                    .foregroundColor(AppConstants.Colors.textPrimary)
                Spacer(minLength: 0)
            }

            PrimaryButton(
                "Enable Notifications",
                isLoading: viewModel.isWorking
            ) {
                Task { await viewModel.requestPermission() }
            }
        }
        .padding(14)
        .background(AppConstants.Colors.primary.opacity(0.1))
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }

    private func infoBanner(text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(AppConstants.Colors.income)
            Text(text)
                .font(.footnote)
                .foregroundColor(AppConstants.Colors.textPrimary)
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(AppConstants.Colors.income.opacity(0.1))
        .cornerRadius(AppConstants.Layout.cornerRadius)
    }

    // MARK: - Bill reminder form

    private var billReminderCard: some View {
        VStack(spacing: 14) {
            InputField(
                icon: "doc.text",
                placeholder: "Bill name (e.g. Electricity)",
                text: $viewModel.billTitle
            )
            
            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            InputField(
                icon: "dollarsign",
                placeholder: "Amount (optional)",
                text: $viewModel.billAmount,
                keyboardType: .decimalPad
            )
            #else
            InputField(
                icon: "dollarsign",
                placeholder: "Amount (optional)",
                text: $viewModel.billAmount
            )
            #endif

            DatePicker(
                "Due",
                selection: $viewModel.billDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .font(.subheadline)
            .foregroundColor(AppConstants.Colors.textPrimary)

            Toggle("Repeat monthly", isOn: $viewModel.billRepeats)
                .font(.subheadline)
                .tint(AppConstants.Colors.primary)

            PrimaryButton(
                "Schedule Reminder",
                isLoading: viewModel.isWorking
            ) {
                Task { await viewModel.scheduleBillReminder() }
            }
        }
        .padding(16)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    // MARK: - Budget alert form

    private var budgetAlertCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Category")
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.textSecondary)
                Spacer()
                Picker("Category", selection: $viewModel.budgetCategory) {
                    ForEach(Category.allCases.filter { $0 != .income }) { cat in
                        Label(cat.displayName, systemImage: cat.icon).tag(cat)
                    }
                }
                .pickerStyle(.menu)
                .tint(AppConstants.Colors.primary)
            }

            #if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            InputField(
                icon: "percent",
                placeholder: "Threshold % (e.g. 80)",
                text: $viewModel.budgetThreshold,
                keyboardType: .numberPad
            )
            #else
            InputField(
                icon: "percent",
                placeholder: "Threshold % (e.g. 80)",
                text: $viewModel.budgetThreshold
            )
            #endif

            Text("You'll be alerted when spending in this category passes the threshold.")
                .font(.caption)
                .foregroundColor(AppConstants.Colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            PrimaryButton(
                "Schedule Alert",
                isLoading: viewModel.isWorking
            ) {
                Task { await viewModel.scheduleBudgetAlert() }
            }
        }
        .padding(16)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    // MARK: - Pending list

    private var pendingCard: some View {
        VStack(spacing: 0) {
            if viewModel.pendingItems.isEmpty {
                Text("No reminders scheduled.")
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(20)
            } else {
                ForEach(viewModel.pendingItems) { item in
                    pendingRow(item)
                    if item.id != viewModel.pendingItems.last?.id {
                        Divider().padding(.leading, 52)
                    }
                }

                Divider().padding(.leading, 16)

                Button {
                    Task { await viewModel.cancelAll() }
                } label: {
                    Text("Clear All")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppConstants.Colors.error)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                }
            }
        }
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private func pendingRow(_ item: NotificationItem) -> some View {
        HStack(spacing: 14) {
            Image(systemName: item.category.icon)
                .font(.title3)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 38, height: 38)
                .background(AppConstants.Colors.primary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .lineLimit(1)
                Text(viewModel.formatted(date: item.fireDate))
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }

            Spacer()

            Button {
                Task { await viewModel.cancel(item) }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
