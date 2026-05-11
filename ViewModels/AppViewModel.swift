// AppViewModel.swift
// MintFlow
//

import SwiftUI
import Combine

// Represents the current screen
enum AppScreen {
    case landing
    case login
    case signup
    case home
    case analytics
    case notifications
}

@MainActor
final class AppViewModel: ObservableObject {

    @Published private(set) var currentScreen: AppScreen = .landing
    @Published private(set) var currentUser: User?
    @Published private(set) var authToken: String?

    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol = ServiceContainer.shared.authService) {
        self.authService = authService
    }

    func navigate(to screen: AppScreen) {
        currentScreen = screen
    }
    func handleAuthSuccess(response: AuthResponse) {
        currentUser = response.user
        authToken = response.token
        currentScreen = .home
    }

    // Clears session data and returns to the landing screen.
    func logout() {
        Task {
            await authService.logout()
            currentUser = nil
            authToken = nil
            currentScreen = .landing
        }
    }
}
