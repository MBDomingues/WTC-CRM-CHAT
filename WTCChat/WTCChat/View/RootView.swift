import SwiftUI

struct RootView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var path = NavigationPath()

    var body: some View {
        Group {
            if authManager.isAuthenticated {
                ContentView()
                    .environmentObject(authManager)
            } else {
                NavigationStack(path: $path) {
                HomeScreen(path: $path)
                    .navigationDestination(for: Route.self) { route in
                        switch route {
                        case .login:
                            LoginScreen(path: $path)
                        case .signUp:
                            SignUpScreen(path: $path)
                        default:
                            EmptyView()
                        }
                    }
                }
            }
        }
        .animation(.easeInOut, value: authManager.isAuthenticated)
    }
}
