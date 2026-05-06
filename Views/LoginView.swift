// LoginView.swift
// MintFlow
//
// Login form

import SwiftUI

struct LoginView: View {

    @EnvironmentObject var appViewModel: AppViewModel
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        ZStack {
            AppConstants.Colors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {

                    VStack(spacing: 8) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppConstants.Colors.primary)

                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppConstants.Colors.textPrimary)

                        Text("Sign in to continue managing your finances")
                            .font(.subheadline)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)

                    VStack(spacing: 16) {
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
                    }

                    if let error = viewModel.errorMessage {
                        ErrorBanner(message: error)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    PrimaryButton("Sign In", isLoading: viewModel.isLoading) {
                        Task {
                            if let response = await viewModel.login() {
                                appViewModel.handleAuthSuccess(response: response)
                            }
                        }
                    }

                    HStack {
                        line
                        Text("OR").font(.caption)
                            .foregroundColor(AppConstants.Colors.textSecondary)
                        line
                    }

                    Button {
                        appViewModel.navigate(to: .signup)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(AppConstants.Colors.textSecondary)
                            Text("Sign Up")
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

    private var line: some View {
        Rectangle()
            .fill(AppConstants.Colors.textSecondary.opacity(0.3))
            .frame(height: 1)
    }
}
