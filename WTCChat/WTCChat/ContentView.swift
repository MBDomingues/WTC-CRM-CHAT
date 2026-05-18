import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab: BottomNavBar.Tab = .chats
    @State private var chatDetailPath = NavigationPath()
    
    @State private var isKeyboardVisible = false
    @State private var isAnnounceSubScreenOpen = false

    var body: some View {
        ZStack {
            Color.primaria.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case .events:
                        EventsScreen(selectedTab: $selectedTab)
                    case .chats:
                        EventsAndChatsView(selectedTab: $selectedTab, chatDetailPath: $chatDetailPath)
                    case .announce:
                        AnnounceScreen(
                            selectedTab: $selectedTab,
                            isSubScreenOpen: $isAnnounceSubScreenOpen
                        )
                    case .config:
                        ConfiguracoesScreen(selectedTab: $selectedTab)
                    case .segments:
                        SegmentsScreen()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .safeAreaInset(edge: .bottom) {
                    if chatDetailPath.isEmpty && !isKeyboardVisible && !isAnnounceSubScreenOpen {
                        BottomNavBar(
                            selectedTab: $selectedTab,
                            isAdmin: authManager.isAdmin
                        )
                        .padding(.horizontal, 8)
                        .padding(.top, 4)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }

        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                isKeyboardVisible = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeOut(duration: 0.25)) {
                isKeyboardVisible = false
            }
        }
        
        .onChange(of: selectedTab) { oldValue, newValue in
            withAnimation(.easeOut(duration: 0.25)) {
                isAnnounceSubScreenOpen = false
            }
        }
    }
}
