import SwiftUI

struct SettingsView: View {
    
    let user: User
    @EnvironmentObject var appViewModel: AppViewModel
    @ObservedObject private var currencyManager = CurrencyManager.shared
    @State private var showingNotificationSettings = false
    @State private var showingAccountInfo = false
    @State private var showingPrivacySecurity = false
    @State private var showingAppearance = false
    @State private var showingCurrency = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    accountSection
                    notificationsSection
                    appearanceSection
                    aboutSection
                    logoutSection
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                .padding(.top, 16)
            }
            .background(AppConstants.Colours.background.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingNotificationSettings) {
                NavigationStack {
                    NotificationSettingsView(user: user)
                        .navigationTitle("Notifications")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    showingNotificationSettings = false
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(AppConstants.Colours.textSecondary)
                                }
                            }
                        }
                }
            }
            .sheet(isPresented: $showingAccountInfo) {
                NavigationStack {
                    AccountInformationView(user: user)
                }
            }
            .sheet(isPresented: $showingPrivacySecurity) {
                NavigationStack {
                    PrivacySecurityView()
                }
            }
            .sheet(isPresented: $showingAppearance) {
                NavigationStack {
                    AppearanceView()
                }
            }
            .sheet(isPresented: $showingCurrency) {
                NavigationStack {
                    CurrencySettingsView()
                }
            }
            .sheet(isPresented: $showingAbout) {
                NavigationStack {
                    AboutView()
                }
            }
        }
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppConstants.Colours.primarySoft)
                    .frame(width: 70, height: 70)
                
                Text(user.fullName.prefix(1).uppercased())
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppConstants.Colours.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(user.fullName)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(AppConstants.Colours.textPrimary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(AppConstants.Colours.textSecondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        SettingsCard {
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "person.fill",
                    title: "Account Information",
                    iconColor: AppConstants.Colours.primary
                ) {
                    showingAccountInfo = true
                }
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsRow(
                    icon: "lock.fill",
                    title: "Privacy & Security",
                    iconColor: AppConstants.Colours.primary
                ) {
                    showingPrivacySecurity = true
                }
            }
        }
    }
    
    // MARK: - Notifications Section
    
    private var notificationsSection: some View {
        SettingsCard {
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    subtitle: "Reminders and alerts",
                    iconColor: AppConstants.Colours.primary,
                    showChevron: true
                ) {
                    showingNotificationSettings = true
                }
            }
        }
    }
    
    // MARK: - Appearance Section
    
    private var appearanceSection: some View {
        SettingsCard {
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "paintbrush.fill",
                    title: "Appearance",
                    subtitle: "Customize your experience",
                    iconColor: AppConstants.Colours.primary
                ) {
                    showingAppearance = true
                }
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsRow(
                    icon: "dollarsign.circle.fill",
                    title: "Currency",
                    subtitle: "\(currencyManager.currentCurrency.code) - \(currencyManager.currentCurrency.name)",
                    iconColor: AppConstants.Colours.primary
                ) {
                    showingCurrency = true
                }
            }
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        SettingsCard {
            VStack(spacing: 0) {
                SettingsRow(
                    icon: "info.circle.fill",
                    title: "About MintFlow",
                    subtitle: "Version 1.0.0",
                    iconColor: AppConstants.Colours.primary
                ) {
                    showingAbout = true
                }
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsRow(
                    icon: "doc.text.fill",
                    title: "Terms & Conditions",
                    iconColor: AppConstants.Colours.primary
                ) {
                    // Show terms (can add later)
                }
                
                Divider()
                    .padding(.leading, 44)
                
                SettingsRow(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    iconColor: AppConstants.Colours.primary
                ) {
                    // Show privacy policy (can add later)
                }
            }
        }
    }
    
    // MARK: - Logout Section
    
    private var logoutSection: some View {
        Button {
            appViewModel.logout()
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(AppConstants.Colours.error)
                
                Text("Log Out")
                    .font(.body.weight(.medium))
                    .foregroundColor(AppConstants.Colours.error)
                
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(AppConstants.Colours.cardBackground)
            .cornerRadius(AppConstants.Layout.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cardCornerRadius)
                    .stroke(AppConstants.Colours.divider, lineWidth: 1)
            )
        }
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
            .background(AppConstants.Colours.cardBackground)
            .cornerRadius(AppConstants.Layout.cardCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cardCornerRadius)
                    .stroke(AppConstants.Colours.divider, lineWidth: 1)
            )
    }
}

// MARK: - Settings Row

private struct SettingsRow: View {
    
    let icon: String
    let title: String
    var subtitle: String?
    let iconColor: Color
    var showChevron: Bool = true
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(AppConstants.Colours.textPrimary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(AppConstants.Colours.textSecondary)
                    }
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppConstants.Colours.textSecondary)
                }
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView(user: User(email: "demo@mintflow.app", fullName: "Demo User"))
        .environmentObject(AppViewModel())
}
