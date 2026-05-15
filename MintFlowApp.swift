import SwiftUI

@main
struct MintFlowApp: App {

	@StateObject private var appViewModel = AppViewModel()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(appViewModel)
				.task {
					await ServiceContainer.shared.bootstrapDatabase()
				}
		}
	}
}
