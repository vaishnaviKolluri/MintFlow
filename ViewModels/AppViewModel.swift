import SwiftUI

enum AppScreen {
	case landing
	case login
	case signup
	case home
}

@MainActor
final class AppViewModel: ObservableObject {

	@Published private(set) var currentScreen: AppScreen = .landing
	@Published private(set) var currentUser: User?
	@Published private(set) var authToken: String?

	private let authService: any AuthServiceProtocol
	private let serviceContainer: ServiceContainer

	init(
		authService: any AuthServiceProtocol = ServiceContainer.shared.authService,
		serviceContainer: ServiceContainer = ServiceContainer.shared
	) {
		self.authService = authService
		self.serviceContainer = serviceContainer
	}

	func navigate(to screen: AppScreen) {
		currentScreen = screen
	}

	func handleAuthSuccess(response: AuthResponse) {
		currentUser = response.user
		authToken = response.token
		currentScreen = .home

		Task { [identifier = response.user.id, container = serviceContainer] in
			await container.seedSampleData(for: identifier)
		}
	}

	func logout() {
		Task {
			await authService.logout()
			currentUser = nil
			authToken = nil
			currentScreen = .landing
		}
	}
}
