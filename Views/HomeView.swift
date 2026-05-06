// HomeView.swift
// MintFlow
//
// Post-login dashboard

import SwiftUI

struct HomeView: View {

    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        let user = appViewModel.currentUser ?? User(email: "demo@mintflow.app", fullName: "Demo User")
        let viewModel = HomeViewModel(user: user)

        ZStack {
            AppConstants.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    topBar(viewModel: viewModel)

                    balanceCard(viewModel: viewModel)

                    SectionHeader(title: "Quick Actions")
                    quickActions

                    SectionHeader(title: "Recent Transactions")
                    transactionList(viewModel: viewModel)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                .padding(.top, 16)
            }
        }
    }

    private func topBar(viewModel: HomeViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(viewModel.firstName)!")
                    .font(.title2.weight(.bold))
                    .foregroundColor(AppConstants.Colors.textPrimary)

                Text("Here's your financial overview")
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }

            Spacer()

            // Logout
            Button {
                appViewModel.logout()
            } label: {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .padding(10)
                    .background(AppConstants.Colors.cardBackground)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            }
        }
    }

    private func balanceCard(viewModel: HomeViewModel) -> some View {
        VStack(spacing: 20) {
            // Total balance
            VStack(spacing: 6) {
                Text("Total Balance")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Text(viewModel.formattedBalance)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            HStack(spacing: 30) {
                balanceStat(
                    icon: "arrow.down.circle.fill",
                    label: "Income",
                    value: "$2,500.00",
                    color: AppConstants.Colors.income
                )
                balanceStat(
                    icon: "arrow.up.circle.fill",
                    label: "Spending",
                    value: viewModel.formattedSpending,
                    color: AppConstants.Colors.expense
                )
            }

            // Savings progress
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Savings Goal")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text("\(Int(viewModel.savingsGoalProgress * 100))%")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                }
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                            .frame(height: 8)
                        Capsule()
                            .fill(Color.white)
                            .frame(
                                width: geo.size.width * viewModel.savingsGoalProgress,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [AppConstants.Colors.primary, AppConstants.Colors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: AppConstants.Colors.primary.opacity(0.3), radius: 12, y: 6)
    }

    private func balanceStat(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }
        }
    }

    private var quickActions: some View {
        HStack(spacing: 16) {
            quickActionTile(icon: "plus.circle.fill",    label: "Add\nExpense")
            quickActionTile(icon: "list.bullet.clipboard", label: "View\nBudgets")
            quickActionTile(icon: "chart.bar.fill",       label: "Analytics")
            quickActionTile(icon: "gearshape.fill",        label: "Settings")
        }
    }

    private func quickActionTile(icon: String, label: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(AppConstants.Colors.primary)

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private func transactionList(viewModel: HomeViewModel) -> some View {
        VStack(spacing: 0) {
            ForEach(viewModel.recentTransactions) { txn in
                transactionRow(txn)
                if txn.id != viewModel.recentTransactions.last?.id {
                    Divider().padding(.leading, 52)
                }
            }
        }
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.Layout.cardCornerRadius)
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
    }

    private func transactionRow(_ txn: Transaction) -> some View {
        HStack(spacing: 14) {
            Image(systemName: txn.category.icon)
                .font(.title3)
                .foregroundColor(AppConstants.Colors.primary)
                .frame(width: 38, height: 38)
                .background(AppConstants.Colors.primary.opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(txn.note)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                Text(txn.category.displayName)
                    .font(.caption)
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }

            Spacer()

            Text("\(txn.type == .expense ? "-" : "+")$\(txn.amount)")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(
                    txn.type == .expense
                        ? AppConstants.Colors.expense
                        : AppConstants.Colors.income
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
