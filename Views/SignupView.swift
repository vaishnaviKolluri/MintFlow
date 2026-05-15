// SignupView.swift
// MintFlow
//
// Registration form

import SwiftUI

struct SignupView: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = SignupViewModel()

    var body: some View {
        ZStack {
            AppConstants.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {

                    VStack(spacing: 8) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppConstants.Colors.primary)

                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppConstants.Colors.textPrimary)

                        Text("Start your journey to smarter spending")
                            .font(.subheadline)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)

                    VStack(spacing: 16) {
                        InputField(
                            icon: "person.fill",
                            placeholder: "Full name",
                            text: $viewModel.fullName
                        )

                        InputField(
                            icon: "envelope.fill",
                            placeholder: "Email address",
                            text: $viewModel.email,
                            isEmail: true
                        )

                        InputField(
                            icon: "lock.fill",
                            placeholder: "Password",
                            text: $viewModel.password,
                            isSecure: true
                        )

                        InputField(
                            icon: "lock.shield.fill",
                            placeholder: "Confirm password",
                            text: $viewModel.confirmPassword,
                            isSecure: true
                        )
                    }

                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        Text("Min 8 characters, with uppercase, lowercase, and a number.")
                            .font(.caption)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        Spacer()
                    }

                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    PrimaryButton("Create Account", isLoading: viewModel.isLoading) {
                        Task {
                            if let response = await viewModel.register() {
                                appViewModel.handleAuthSuccess(response: response)
                            }
                        }
                    }

                    Button {
                        appViewModel.navigate(to: .login)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(AppConstants.Colors.textSecondary)
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .foregroundColor(AppConstants.Colors.primary)
                        }
                        .font(.subheadline)
                    }

                    Spacer()
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
        .overlay(alignment: .topLeading) {
            BackButton { appViewModel.navigate(to: .landing) }
        }
    }
}
