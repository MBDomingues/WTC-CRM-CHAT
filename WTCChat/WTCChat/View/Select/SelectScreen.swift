import SwiftUI

struct SelectScreen: View {
    @ObservedObject var viewModel: AnnounceViewModel
    @Binding var selectedTab: BottomNavBar.Tab
    @Environment(\.dismiss) var dismiss

    @State private var searchQuery = ""
    @State private var showingSegmentModal = false // ✨ Controle do Modal

    private var hasSelection: Bool {
        viewModel.destinatarios.contains { $0.selecionado }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Títulos
            VStack(alignment: .leading, spacing: 4) {
                Text("Selecione quem")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.secundaria)
                Text("Vai receber")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.branco)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.cinza)
                TextField("Pesquisar clientes ou grupos...", text: $searchQuery)
                    .foregroundColor(.branco)
                    .onSubmit {
                        Task {
                            await viewModel.fetchDestinatarios(search: searchQuery, segmentIds: viewModel.selectedSegmentIds)
                        }
                    }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(Color.fundoBotao.opacity(0.1))
            .cornerRadius(28)
            .padding(.horizontal, 16)

            Spacer().frame(height: 16)

            // ✨ NOVO BOTÃO DE FILTRO DE SEGMENTOS ✨
            if !viewModel.availableSegments.isEmpty {
                Button {
                    showingSegmentModal = true
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title3)
                        
                        Text(viewModel.selectedSegmentIds.isEmpty ? "Filtrar por Segmento" : "Segmentos Selecionados (\(viewModel.selectedSegmentIds.count))")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(viewModel.selectedSegmentIds.isEmpty ? .cinza : .secundaria)
                    .padding()
                    .background(Color.fundoBotao.opacity(0.1))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }

            // LISTA DE DESTINATÁRIOS
            if viewModel.isLoadingDestinatarios {
                Spacer()
                ProgressView("Carregando lista...")
                    .tint(.secundaria)
                    .foregroundColor(.cinza)
                Spacer()
            } else if viewModel.destinatarios.isEmpty {
                Spacer()
                Text("Nenhum destinatário localizado.")
                    .foregroundColor(.cinza)
                Spacer()
            } else {
                List(viewModel.destinatarios) { d in
                    let selected = viewModel.destinatarios.first(where: { $0.id == d.id })?.selecionado ?? false
                    DestinatarioItem(
                        nome: d.nome,
                        imageUrl: d.imagemUrl,
                        isGroup: d.isGroup,
                        selected: selected
                    ) {
                        if let index = viewModel.destinatarios.firstIndex(where: { $0.id == d.id }) {
                            viewModel.destinatarios[index].selecionado.toggle()
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color.primaria)
            }

            Spacer().frame(height: 16)

            Button {
                Task {
                    let selecionadosIds = viewModel.destinatarios
                        .filter { $0.selecionado }
                        .map { $0.id }
                    
                    await viewModel.sendAnnouncement(recipientIds: selecionadosIds)
                }
            } label: {
                if viewModel.isSending {
                    ProgressView().tint(.branco)
                } else {
                    Text("Enviar")
                        .font(.system(size: 18, weight: .bold))
                }
            }
            .foregroundColor(.branco)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(hasSelection && !viewModel.isSending ? Color.azul : Color.fundoBotao.opacity(0.3))
            .cornerRadius(27)
            .disabled(!hasSelection || viewModel.isSending)
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
            
        }
        .background(Color.primaria)
        .toolbar(.hidden, for: .tabBar)
        .task {
            await viewModel.fetchSegments()
            await viewModel.fetchDestinatarios(search: nil, segmentIds: [])
        }
        .appPopup(data: $viewModel.popup) { closedPopup in
            if closedPopup.type == .success {
                selectedTab = .chats
                dismiss()
            }
        }
        .sheet(isPresented: $showingSegmentModal) {
            SegmentSelectionModal(
                availableSegments: viewModel.availableSegments,
                selectedSegmentIds: $viewModel.selectedSegmentIds
            ) {
                Task {
                    await viewModel.fetchDestinatarios(search: searchQuery, segmentIds: viewModel.selectedSegmentIds)
                }
            }
        }
    }
}

struct SegmentSelectionModal: View {
    let availableSegments: [Segment]
    @Binding var selectedSegmentIds: Set<String>
    let onConfirm: () -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var tempSelection: Set<String> = []

    var body: some View {
        NavigationView {
            List {
                ForEach(availableSegments, id: \.id) { segment in
                    Button {
                        if tempSelection.contains(segment.id) {
                            tempSelection.remove(segment.id)
                        } else {
                            tempSelection.insert(segment.id)
                        }
                    } label: {
                        HStack {
                            Text(segment.name)
                                .foregroundColor(.branco)
                            Spacer()
                            if tempSelection.contains(segment.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.secundaria)
                                    .font(.title3)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.cinza)
                                    .font(.title3)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .listRowBackground(Color.fundoBotao.opacity(0.1))
                    .padding(.vertical, 4)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.primaria.ignoresSafeArea())
            .navigationTitle("Filtrar Segmentos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.cinza)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Confirmar") {
                        selectedSegmentIds = tempSelection
                        onConfirm()
                        dismiss()
                    }
                    .foregroundColor(.secundaria)
                    .bold()
                }
            }
            .onAppear {
                tempSelection = selectedSegmentIds
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct DestinatarioItem: View {
    let nome: String
    let imageUrl: String
    let isGroup: Bool
    let selected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                
                CachedAsyncImage(
                    urlString: imageUrl,
                    cacheKey: nome,
                    placeholderSystemName: isGroup ? "person.3.fill" : "person.circle.fill",
                    isGroup: isGroup
                )
                .frame(width: 48, height: 48)
                .background(imageUrl.isEmpty && isGroup ? Color.branco.opacity(0.1) : Color.clear)
                .clipShape(Circle())

                Text(nome)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.branco)

                Spacer()

                Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(selected ? .secundaria : .cinza)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(selected ? Color.azul.opacity(0.15) : Color.fundoBotao.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selected ? Color.secundaria : Color.clear, lineWidth: 1)
            )
        }
    }
}
