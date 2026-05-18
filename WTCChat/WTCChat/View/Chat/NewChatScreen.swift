import SwiftUI

struct NewChatScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = NewChatViewModel()
    @Binding var chatDetailPath: NavigationPath
    @Binding var isNewChatModalPresented: Bool
    @State private var isShowingMemberSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.cinza)
                    TextField("Buscar cliente por nome...", text: $viewModel.searchText)
                        .foregroundColor(.branco)
                        .autocorrectionDisabled()
                        .onChange(of: viewModel.searchText) {
                            Task { await viewModel.fetchCustomers() }
                        }
                }
                .padding()
                .background(Color.fundoBotao.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView().tint(.secundaria)
                    Spacer()
                } else if viewModel.customers.isEmpty && !viewModel.searchText.isEmpty {
                    Spacer()
                    Text("Nenhum cliente encontrado.")
                        .foregroundColor(.cinza)
                    Spacer()
                } else {
                    List(viewModel.customers) { customer in
                        Button {
                            dismiss()
                            let route = ChatDetailRoute(
                                chatId: customer.id,
                                participantName: customer.name,
                                participantAvatarUrl: customer.imageUrl ?? ""
                            )
                            chatDetailPath.append(route)
                        } label: {
                            HStack {
                                CachedAsyncImage(
                                    urlString: customer.imageUrl,
                                    cacheKey: customer.id,
                                    placeholderSystemName: "person.circle.fill"
                                )
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                
                                Text(customer.name)
                                    .foregroundColor(.branco)
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                }
            }
            .background(Color.primaria.ignoresSafeArea())
            .navigationTitle("Nova Conversa")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.cinza)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingMemberSelection = true
                    } label: {
                        Text("Novo Grupo")
                            .fontWeight(.semibold)
                            .foregroundColor(.secundaria)
                    }
                }
            }
            .task {
                await viewModel.fetchCustomers()
            }
            .navigationDestination(isPresented: $isShowingMemberSelection) {
                SelectGroupMembersScreen(
                    chatDetailPath: $chatDetailPath,
                    isNewChatModalPresented: $isNewChatModalPresented
                )
            }
        }
    }
}
