import UIKit
import SwiftUI
import Kingfisher

struct ChatDetailScreen: View {
    @StateObject private var viewModel: ChatDetailViewModel
    
    @State private var hasInitialScrolled = false
    @State private var hasScrolledToBottom = false
    @State private var currentZoomImageUrl: String? = nil
    
    @State private var isShowingProfile360 = false

    let chatId: String
    let participantName: String
    let participantAvatarUrl: String

    init(chatId: String, participantName: String, participantAvatarUrl: String) {
        self.chatId = chatId
        self.participantName = participantName
        self.participantAvatarUrl = participantAvatarUrl
        self._viewModel = StateObject(wrappedValue: ChatDetailViewModel(chatId: chatId))
    }

    var body: some View {
        ZStack {
            Color.primaria.ignoresSafeArea()

            VStack(spacing: 0) {
                if viewModel.isLoading && viewModel.messages.isEmpty {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .secundaria))
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.messages) { message in
                                    MessageBubble(message: message) {
                                        Task {
                                            await viewModel.fetchMessages()
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                        }
                        .defaultScrollAnchor(.bottom)
                        
                        .onChange(of: viewModel.messages.count) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                proxy.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                            }
                        }
                    }
                }

                HStack(spacing: 0) {
                    TextField("Mensagem", text: $viewModel.currentMessage)
                        .textInputAutocapitalization(.sentences)
                        .disableAutocorrection(true)
                        .foregroundColor(.branco)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(hex: "37474F"))
                        .cornerRadius(24)

                    Button {
                        Task { await viewModel.sendMessage() }
                    } label: {
                        Image(systemName: "arrow.up")
                            .foregroundColor(.primaria)
                            .frame(width: 48, height: 48)
                            .background(Color.secundaria)
                            .clipShape(Circle())
                    }
                    .padding(.leading, 8)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color.primaria)
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchMessages()
            }
        }
        .onDisappear {
            viewModel.stopSignalR()
            viewModel.messages = []
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button {
                    isShowingProfile360 = true
                } label: {
                    HStack(spacing: 10) {
                        CachedAsyncImage(
                            urlString: participantAvatarUrl,
                            cacheKey: chatId,
                            placeholderSystemName: "person.circle.fill"
                        )
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(participantName)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.branco)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .toolbarBackground(Color(hex: "1E2A32"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        
        .sheet(isPresented: $isShowingProfile360) {
            NavigationStack {
                Profile360Screen(customerId: chatId)
            }
        }
    }
}

// MARK: - MessageBubble e Auxiliares permanecem iguais
struct MessageBubble: View {
    let message: Message
    var onRetry: () -> Void
    
    @State private var imageFailed = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
        
            if !message.isSentByMe, message.senderName != nil {
                CachedAsyncImage(
                    urlString: message.senderPhotoUrl ?? "",
                    cacheKey: message.senderId ?? message.id,
                    placeholderSystemName: "person.circle.fill"
                )
                .frame(width: 32, height: 32)
                .background(Color.branco.opacity(0.1))
                .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 8) {
                
                if !message.isSentByMe, let senderName = message.senderName {
                    Text(senderName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.azul)
                }
                
                if let title = message.title {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.secundaria)
                }
                
                if let imageUrl = message.url, let url = URL(string: imageUrl) {
                    let resource = KF.ImageResource(downloadURL: url, cacheKey: url.path)
                    KFImage(source: .network(resource))
                        .resizable()
                        .placeholder {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .background(Color.branco.opacity(0.05))
                                .cornerRadius(12)
                        }
                        .onSuccess { _ in imageFailed = false }
                        .onFailure { _ in imageFailed = true }
                        .fade(duration: 0.25)
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            Group {
                                if imageFailed {
                                    VStack(spacing: 12) {
                                        Image(systemName: "photo.badge.exclamationmark")
                                            .font(.system(size: 30))
                                            .foregroundColor(.cinza)
                                        Text("Link expirado ou falha na rede")
                                            .font(.caption)
                                            .foregroundColor(.cinza)
                                        Button {
                                            imageFailed = false
                                            onRetry()
                                        } label: {
                                            Label("Recarregar", systemImage: "arrow.clockwise")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 20)
                                                .background(Color.secundaria)
                                                .foregroundColor(.primaria)
                                                .cornerRadius(25)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.85))
                                    .cornerRadius(12)
                                }
                            }
                        )
                }
                
                Text(message.text)
                    .font(.system(size: 16))
                    .foregroundColor(.branco)
                
                if let actions = message.actions {
                    VStack(spacing: 8) {
                        ForEach(actions, id: \.action) { action in
                            Button {
                                if let urlString = message.actionUrls?[action.action],
                                   let url = URL(string: urlString) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Text(action.title)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(Color.branco.opacity(0.15))
                                    .foregroundColor(.branco)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                HStack(spacing: 4) {
                    Text(message.timestamp)
                        .font(.system(size: 10))
                        .foregroundColor(.cinza.opacity(0.7))
                    
                    if message.isSentByMe, let status = message.status {
                        Image(systemName: status.iconName)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(status.iconColor)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(12)
            .background(message.isSentByMe ? Color.sentBubble : Color.receivedBubble)
            .cornerRadius(16, corners: [
                .topLeft, .topRight,
                message.isSentByMe ? .bottomLeft : .bottomRight
            ])
            
            if message.isSentByMe {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isSentByMe ? .trailing : .leading)
        .padding(.leading, message.isSentByMe ? 60 : 8)
        .padding(.trailing, message.isSentByMe ? 8 : 60)
        .padding(.vertical, 4)
        .id(message.id)
    }
}

// MARK: - Extensões de Layout
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
