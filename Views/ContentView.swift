import SwiftUI

struct ContentView: View {

	@EnvironmentObject var appViewModel: AppViewModel

	var body: some View {
		Group {
			switch appViewModel.currentScreen {
			case .landing:
				LandingView()
			case .login:
				LoginView()
			case .signup:
				SignupView()
			case .home:
				MainTabView()
			}
		}
		.animation(.easeInOut(duration: 0.35), value: appViewModel.currentScreen)
	}
}
