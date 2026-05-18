import SwiftUI

struct ChatsScreen: View {
    @StateObject private var viewModel = ChatViewModel()
    @Binding var chatDetailPath: NavigationPath
    @State private var isShowingNewChat = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                HStack {
                    Text("Mensagens")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.secundaria)
                    Spacer()
                    Button {
                        isShowingNewChat = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 28))
                            .foregroundColor(.secundaria)
                    }
                }

                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.cinza)
                    TextField("Pesquisar conversas...", text: $viewModel.searchText)
                        .foregroundColor(.branco)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 12)
                .frame(height: 38)
                .background(Color.fundoBotao.opacity(0.1))
                .cornerRadius(24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            if viewModel.isLoading && viewModel.filteredChats.isEmpty {
                Spacer()
                ProgressView().tint(.secundaria)
                Spacer()
            } else {
                List(viewModel.filteredChats) { chat in
                    ChatItem(chat: chat) {
                        let route = ChatDetailRoute(
                            chatId: chat.id,
                            participantName: chat.senderName,
                            participantAvatarUrl: chat.profilePicUrl ?? ""
                        )
                        
                        chatDetailPath.append(route)
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 2, leading: 16, bottom: 2, trailing: 16))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.primaria)
                .refreshable {
                    await viewModel.fetchChats()
                }
            }
        }
        .background(Color.primaria)
        .navigationBarHidden(true)
        
        .sheet(isPresented: $isShowingNewChat) {
            NewChatScreen(
                chatDetailPath: $chatDetailPath,
                isNewChatModalPresented: $isShowingNewChat
            )
        }
        .onAppear {
            Task {
                await viewModel.fetchChats()
            }
        }
        .onChange(of: chatDetailPath) {
            if chatDetailPath.isEmpty {
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    
                    await viewModel.fetchChats()
                }
            }
        }
    }
}

struct ChatItem: View {
    let chat: Chat
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 16) {
                
                CachedAsyncImage(
                    urlString: chat.profilePicUrl,
                    cacheKey: chat.id,
                    placeholderSystemName: chat.isGroup ? "person.3.fill" : "person.circle.fill",
                    isGroup: chat.isGroup
                )
                .frame(width: 60, height: 60)
                .background(chat.profilePicUrl == nil && chat.isGroup ? Color.branco.opacity(0.1) : Color.clear)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(chat.senderName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.branco)
                    
                    HStack(spacing: 4) {
                        Text(chat.lastMessage)
                            .font(.system(size: 14))
                            .foregroundColor(chat.isRead ? .cinza : .branco)
                            .lineLimit(1)
                        
                        if chat.isLastMessageMine == true, let status = chat.lastMessageStatus {
                            Image(systemName: status.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(status.iconColor)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(chat.timestamp)
                        .font(.system(size: 12))
                        .foregroundColor(chat.isRead ? .cinza : .secundaria)
                    
                    if chat.isRead == false {
                        Circle()
                            .fill(Color.secundaria)
                            .frame(width: 12, height: 12)
                    } else {
                        Spacer().frame(height: 12)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 8)
        }
    }
}
