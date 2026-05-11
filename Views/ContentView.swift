// ContentView.swift
// MintFlow
//

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
                HomeView()
            case .analytics:
                let user = appViewModel.currentUser
                    ?? User(email: "demo@mintflow.app", fullName: "Demo User")
                AnalyticsView(user: user)
            case .notifications:
                NotificationsView()
            }
        }
        .animation(.easeInOut(duration: 0.35), value: appViewModel.currentScreen)
    }
}
