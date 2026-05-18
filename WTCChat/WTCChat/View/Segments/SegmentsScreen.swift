import SwiftUI

struct SegmentsScreen: View {
    @StateObject private var viewModel = SegmentsViewModel()
    
    @State private var showingAddSheet = false
    @State private var editingSegment: Segment? = nil
    
    @State private var showingDeleteAlert = false
    @State private var segmentToDelete: Segment? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaria.ignoresSafeArea()
                
                if viewModel.isLoading && viewModel.segments.isEmpty {
                    ProgressView().tint(.secundaria)
                } else if viewModel.segments.isEmpty {
                    VStack {
                        Image(systemName: "tag.slash").font(.system(size: 50)).foregroundColor(.cinza)
                        Text("Nenhum segmento.").foregroundColor(.cinza).padding(.top, 8)
                    }
                } else {
                    List {
                        ForEach(viewModel.segments) { segment in
                            HStack(spacing: 15) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(segment.name).font(.headline).foregroundColor(.branco)
                                    if let desc = segment.description, !desc.isEmpty {
                                        Text(desc).font(.subheadline).foregroundColor(.cinza)
                                    }
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 12) {
                                    Button {
                                        editingSegment = segment
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    
                                    Button {
                                        segmentToDelete = segment
                                        showingDeleteAlert = true
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .listRowBackground(Color(hex: "1E2A32"))
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Segmentos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus").foregroundColor(.secundaria)
                    }
                }
            }
            .onAppear { Task { await viewModel.fetchSegments() } }
            
            .sheet(isPresented: $showingAddSheet) {
                SegmentFormSheet(viewModel: viewModel, editingSegment: nil)
            }
            
            .sheet(item: $editingSegment) { segment in
                SegmentFormSheet(viewModel: viewModel, editingSegment: segment)
            }
            
            .alert("Excluir Segmento", isPresented: $showingDeleteAlert, presenting: segmentToDelete) { segment in
                Button("Excluir", role: .destructive) {
                    Task { await viewModel.deleteSegmentById(segment.id) }
                }
                Button("Cancelar", role: .cancel) { segmentToDelete = nil }
            } message: { segment in
                Text("Deseja deletar '\(segment.name)'?")
            }
        }
    }
}

struct SegmentFormSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SegmentsViewModel
    var editingSegment: Segment?
    
    @State private var name = ""
    @State private var description = ""
    
    var body: some View {
        ZStack {
            Color.primaria.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.secundaria)
                    Spacer()
                    Text(editingSegment == nil ? "Novo Segmento" : "Editar Segmento")
                        .font(.headline).foregroundColor(.branco)
                    Spacer()
                    Text("Cancelar").opacity(0)
                }
                .padding(.bottom, 10)
                
                TextField("Nome do Segmento", text: $name)
                    .padding().background(Color(hex: "37474F")).foregroundColor(.branco).cornerRadius(12)
                
                TextField("Descrição...", text: $description)
                    .padding().background(Color(hex: "37474F")).foregroundColor(.branco).cornerRadius(12)
                
                Spacer()
                
                Button {
                    Task {
                        let success: Bool
                        if let segment = editingSegment {
                            success = await viewModel.updateSegment(id: segment.id, name: name, description: description)
                        } else {
                            success = await viewModel.createSegment(name: name, description: description)
                        }
                        if success { dismiss() }
                    }
                } label: {
                    Text(viewModel.isLoading ? "Salvando..." : "Salvar Segmento")
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(name.isEmpty ? Color.cinza : Color.secundaria)
                        .foregroundColor(name.isEmpty ? .branco : .primaria)
                        .cornerRadius(12)
                }
                .disabled(name.isEmpty || viewModel.isLoading)
            }
            .padding()
            .onAppear { loadData() }
        }
    }
    
    private func loadData() {
        if let segment = editingSegment {
            name = segment.name
            description = segment.description ?? ""
        }
    }
}
