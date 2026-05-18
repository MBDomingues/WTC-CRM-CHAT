import SwiftUI

struct EventsScreen: View {
    @Binding var selectedTab: BottomNavBar.Tab
    
    @StateObject private var viewModel = EventsViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Mural de")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.secundaria)
                        
                        Text("Novidades")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.branco)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.cinza)
                        TextField("Pesquisar eventos", text: $viewModel.searchQuery)
                            .foregroundColor(.branco)
                            .autocorrectionDisabled()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color.fundoBotao.opacity(0.1))
                    .cornerRadius(28)
                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 8)

                if viewModel.isLoading && viewModel.eventos.isEmpty {
                    Spacer()
                    ProgressView().tint(.secundaria)
                    Spacer()
                } else if viewModel.eventos.isEmpty {
                    Spacer()
                    Text("Nenhum evento encontrado.")
                        .foregroundColor(.cinza)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredEventos) { evento in
                            
                            NavigationLink(destination: EventoDetailScreen(evento: evento)) {
                                EventoCard(evento: evento)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .padding(.trailing, -20)
                            .onAppear {
                                if evento.id == viewModel.eventos.last?.id {
                                    Task { await viewModel.fetchAnnouncements() }
                                }
                            }
                        }
                        
                        if viewModel.isLoading && viewModel.currentPage > 1 {
                            HStack {
                                Spacer()
                                ProgressView("Carregando mais eventos...")
                                    .tint(.secundaria)
                                    .padding()
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                        }
                    }
                    .environment(\.defaultMinListRowHeight, 0)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.primaria)
                    .refreshable {
                        await viewModel.fetchAnnouncements(isRefresh: true)
                    }
                }
            }
            .background(Color.primaria)
        }
        .task {
            await viewModel.fetchAnnouncements()
        }
    }
}

struct EventoCard: View {
    let evento: AnnouncementItem

    var body: some View {
        HStack(spacing: 16) {

            CachedAsyncImage(
                urlString: evento.imageUrl,
                cacheKey: evento.id,
                placeholderSystemName: "photo"
            )
            .frame(width: 100, height: 100)
            .background(Color.cinza.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text(evento.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.branco)
                    .lineLimit(2)
                
                Text(evento.description)
                    .font(.system(size: 12))
                    .foregroundColor(.cinza)
                    .lineLimit(2)
                
                Text(evento.date)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.8))
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.azul.opacity(0.1))
        .cornerRadius(16)
    }
}
