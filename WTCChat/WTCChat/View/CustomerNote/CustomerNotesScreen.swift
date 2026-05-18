import SwiftUI

struct CustomerNotesScreen: View {
    let customerId: String
    @StateObject private var viewModel: CustomerNotesViewModel
    
    @State private var showingAddSheet = false
    @State private var editingNote: CustomerNote? = nil
    
    @State private var showingDeleteAlert = false
    @State private var noteToDelete: CustomerNote? = nil
    
    init(customerId: String) {
        self.customerId = customerId
        _viewModel = StateObject(wrappedValue: CustomerNotesViewModel(customerId: customerId))
    }
    
    var body: some View {
        ZStack {
            Color.primaria.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.notes.isEmpty {
                ProgressView().tint(.secundaria)
            } else if viewModel.notes.isEmpty {
                VStack {
                    Image(systemName: "note.text")
                        .font(.system(size: 50))
                        .foregroundColor(.cinza)
                    Text("Nenhuma anotação ou tarefa.")
                        .foregroundColor(.cinza)
                        .padding(.top, 8)
                }
            } else {
                List {
                    ForEach(viewModel.notes) { note in
                        CustomerNoteRow(note: note)
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    noteToDelete = note
                                    showingDeleteAlert = true
                                } label: { Label("Excluir", systemImage: "trash.fill") }
                                
                                Button {
                                    // ✨ GATILHO DA EDIÇÃO ✨
                                    editingNote = note
                                } label: { Label("Editar", systemImage: "pencil") }
                                .tint(.blue)
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Anotações e Tarefas")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.secundaria)
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchNotes() }
        }
        
        .sheet(isPresented: $showingAddSheet) {
            NoteFormSheet(viewModel: viewModel, editingNote: nil)
        }
        
        .sheet(item: $editingNote) { note in
            NoteFormSheet(viewModel: viewModel, editingNote: note)
        }
        
        .alert("Excluir Anotação", isPresented: $showingDeleteAlert, presenting: noteToDelete) { note in
            Button("Excluir", role: .destructive) {
                Task { await viewModel.deleteNoteById(note.id) }
            }
            Button("Cancelar", role: .cancel) { noteToDelete = nil }
        } message: { note in
            Text("Tem certeza que deseja excluir esta anotação?")
        }
    }
}

// MARK: - Row Visual da Nota
struct CustomerNoteRow: View {
    let note: CustomerNote
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: note.isTask ? "calendar.badge.exclamationmark" : "note.text")
                Text(note.isTask ? "Tarefa" : "Nota").font(.caption).bold()
                Spacer()
                if note.isTask {
                    Text(note.isResolved ? "Resolvido" : "Pendente")
                        .font(.caption2)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(note.isResolved ? Color.green : Color.red)
                        .cornerRadius(4)
                }
            }
            .foregroundColor(.secundaria)
            
            Text(note.text)
                .font(.subheadline)
                .foregroundColor(.branco)
            
            HStack {
                Spacer()
                Text(note.createdAt.formatted(date: .numeric, time: .shortened))
                    .font(.system(size: 10))
                    .foregroundColor(.cinza)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.branco.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Sheet de Formulário (Criação/Edição)
struct NoteFormSheet: View {
    @Environment(\.dismiss) var dismiss // ✨ FECHAMENTO MODERNO
    @ObservedObject var viewModel: CustomerNotesViewModel
    var editingNote: CustomerNote?
    
    @State private var text = ""
    @State private var isTask = false
    @State private var isResolved = false
    
    var body: some View {
        ZStack {
            Color.primaria.ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.secundaria)
                    Spacer()
                    Text(editingNote == nil ? "Nova Anotação" : "Editar Anotação")
                        .font(.headline).foregroundColor(.branco)
                    Spacer()
                    Text("Cancelar").opacity(0)
                }
                .padding(.bottom, 10)
                
                TextField("Digite os detalhes aqui...", text: $text, axis: .vertical)
                    .lineLimit(4...8)
                    .padding()
                    .background(Color(hex: "37474F"))
                    .foregroundColor(.branco)
                    .cornerRadius(12)
                
                Toggle(isOn: $isTask) {
                    Text("É uma tarefa? (Requer ação)")
                        .foregroundColor(.branco)
                        .font(.subheadline)
                }
                .tint(.secundaria)
                
                if isTask && editingNote != nil {
                    Toggle(isOn: $isResolved) {
                        Text("Tarefa Resolvida")
                            .foregroundColor(.branco)
                            .font(.subheadline)
                    }
                    .tint(.green)
                }
                
                Spacer()
                
                Button {
                    Task {
                        let success: Bool
                        if let note = editingNote {
                            success = await viewModel.updateNote(noteId: note.id, text: text, isTask: isTask, isResolved: isResolved)
                        } else {
                            success = await viewModel.createNote(text: text, isTask: isTask)
                        }
                        if success { dismiss() }
                    }
                } label: {
                    Text(viewModel.isLoading ? "Salvando..." : "Salvar")
                        .font(.headline).frame(maxWidth: .infinity).padding()
                        .background(text.isEmpty ? Color.cinza : Color.secundaria)
                        .foregroundColor(text.isEmpty ? .branco : .primaria)
                        .cornerRadius(12)
                }
                .disabled(text.isEmpty || viewModel.isLoading)
            }
            .padding()
            .onAppear { loadData() }
        }
    }
    
    private func loadData() {
        if let note = editingNote {
            text = note.text
            isTask = note.isTask
            isResolved = note.isResolved
        }
    }
}
