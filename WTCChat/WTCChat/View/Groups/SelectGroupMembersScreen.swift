import SwiftUI
import Combine

struct SelectGroupMembersScreen: View {
    @StateObject private var viewModel = CustomerSelectionViewModel()
    @Binding var chatDetailPath: NavigationPath
    @Binding var isNewChatModalPresented: Bool
    
    @State private var isShowingCreateForm = false

    var body: some View {
        VStack {
            if !viewModel.selectedCustomerIds.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        let selectedCustomers = viewModel.customers.filter { viewModel.selectedCustomerIds.contains($0.id) }
                        ForEach(selectedCustomers) { customer in
                            VStack {
                                CachedAsyncImage(
                                    urlString: customer.imageUrl,
                                    cacheKey: customer.id,
                                    placeholderSystemName: "person.circle.fill"
                                )
                                .frame(width: 48, height: 48)
                                .clipShape(Circle())
                                
                                Text(customer.name.components(separatedBy: " ").first ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.branco)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 70)
                .padding(.top, 16)
            }
            
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.cinza)
                TextField("Buscar contatos...", text: $viewModel.searchText)
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
            .padding(.top, viewModel.selectedCustomerIds.isEmpty ? 16 : 8)
            
            List(viewModel.customers) { customer in
                Button {
                    if viewModel.selectedCustomerIds.contains(customer.id) {
                        viewModel.selectedCustomerIds.remove(customer.id)
                    } else {
                        viewModel.selectedCustomerIds.insert(customer.id)
                    }
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
                        
                        Spacer()

                        if viewModel.selectedCustomerIds.contains(customer.id) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.secundaria)
                                .font(.title3)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.cinza)
                                .font(.title3)
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
        }
        .background(Color.primaria.ignoresSafeArea())
        .navigationTitle("Adicionar Participantes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Avançar") {
                    isShowingCreateForm = true
                }
                .fontWeight(.bold)
                .foregroundColor(viewModel.selectedCustomerIds.isEmpty ? .cinza : .secundaria)
                .disabled(viewModel.selectedCustomerIds.isEmpty)
            }
        }
        .task {
            await viewModel.fetchCustomers()
        }
        .navigationDestination(isPresented: $isShowingCreateForm) {
            CreateGroupScreen(
                initialSelectedMemberIds: viewModel.selectedCustomerIds,
                chatDetailPath: $chatDetailPath,
                isNewChatModalPresented: $isNewChatModalPresented
            )
        }
    }
}

