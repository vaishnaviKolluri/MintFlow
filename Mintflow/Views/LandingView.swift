// LandingView.swift
// MintFlow
//

import SwiftUI

struct LandingView: View {

    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppConstants.Colors.primary, AppConstants.Colors.primaryDark],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 16) {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)

                    Text(AppConstants.appName)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(AppConstants.appTagline)
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.85))
                }

                Spacer()

                VStack(spacing: 14) {
                    featureRow(icon: "chart.pie.fill",  text: "Track spending by category")
                    featureRow(icon: "target",          text: "Set and hit savings goals")
                    featureRow(icon: "bell.badge.fill",  text: "Smart budget alerts")
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)

                Spacer()

                VStack(spacing: 14) {
                    Button {
                        appViewModel.navigate(to: .signup)
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white)
                            .foregroundColor(AppConstants.Colors.primaryDark)
                            .cornerRadius(AppConstants.Layout.cornerRadius)
                            .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    }

                    Button {
                        appViewModel.navigate(to: .login)
                    } label: {
                        Text("I already have an account")
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white)
                            .underline()
                    }
                }
                .padding(.horizontal, AppConstants.Layout.horizontalPadding)
                .padding(.bottom, 50)
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.white)
                .frame(width: 32)

            Text(text)
                .font(.body)
                .foregroundColor(.white.opacity(0.9))

            Spacer()
        }
    }
}
