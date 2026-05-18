import SwiftUI

struct Profile360Screen: View {
    let customerId: String
    @StateObject private var viewModel = Profile360ViewModel()
    
    @State private var isMessagesExpanded = false
    @State private var showingScoreAlert = false
    
    @State private var draftScoreText = ""
    @State private var draftStatus: String? = nil
    @State private var draftSegmentId: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secundaria))
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    
                } else if let profile = viewModel.profile {
                    
                    VStack(spacing: 8) {
                        CachedAsyncImage(urlString: profile.photoUrl, cacheKey: profile.id, placeholderSystemName: "person.circle.fill")
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        
                        Text(profile.name)
                            .font(.title2).bold()
                            .foregroundColor(.branco)
                        
                        Text(profile.email)
                            .foregroundColor(.cinza)
                    }
                    .padding(.top, 40)
                    
                    VStack(spacing: 12) {
                        
                        Button {
                            draftScoreText = draftScoreText.isEmpty ? "\(profile.score ?? 0)" : draftScoreText
                            showingScoreAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "star.fill")
                                Text("Score").font(.headline)
                                Spacer()
                                let displayScore = draftScoreText.isEmpty ? "\(profile.score ?? 0)" : draftScoreText
                                Text(displayScore)
                                    .font(.caption2).bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.cinza)
                                    .cornerRadius(4)
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.secundaria)
                            .padding()
                            .background(Color.branco.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Menu {
                            ForEach(["Ativo", "Lead", "Convidado", "Inativo", "Bloqueado"], id: \.self) { status in
                                Button(status) { draftStatus = status }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "flag.fill")
                                Text("Status").font(.headline)
                                Spacer()
                                let displayStatus = draftStatus ?? profile.status ?? "N/A"
                                Text(displayStatus)
                                    .font(.caption2).bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.cinza)
                                    .cornerRadius(4)
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.secundaria)
                            .padding()
                            .background(Color.branco.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        // 3. SEGMENTO
                        Menu {
                            Button("Nenhum / Remover") { draftSegmentId = "" }
                            Divider()
                            ForEach(viewModel.availableSegments, id: \.id) { segment in
                                Button(segment.name) { draftSegmentId = segment.id }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "tag.fill")
                                Text("Segmento").font(.headline)
                                Spacer()
                                let currentIdToDisplay = draftSegmentId != nil ? (draftSegmentId == "" ? nil : draftSegmentId) : profile.segmentId
                                let currentSegmentName = viewModel.availableSegments.first(where: { $0.id == currentIdToDisplay })?.name ?? "Nenhum"
                                
                                Text(currentSegmentName)
                                    .font(.caption2).bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.cinza)
                                    .cornerRadius(4)
                            }
                            .contentShape(Rectangle())
                            .foregroundColor(.secundaria)
                            .padding()
                            .background(Color.branco.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    

                    Group {
                        NavigationLink(destination: CustomerNotesScreen(customerId: customerId)) {
                            HStack {
                                Image(systemName: "note.text")
                                Text("Anotações e Tarefas")
                                    .font(.headline)
                                Spacer()
                                if !profile.notesAndTasks.isEmpty {
                                    Text("\(profile.notesAndTasks.count)")
                                        .font(.caption2).bold()
                                        .padding(6)
                                        .background(Color.secundaria.opacity(0.2))
                                        .clipShape(Circle())
                                }
                                Image(systemName: "chevron.right")
                            }
                            .foregroundColor(.secundaria)
                            .padding()
                            .background(Color.branco.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        DisclosureGroup(isExpanded: $isMessagesExpanded) {
                            VStack(spacing: 10) {
                                if profile.recentMessages.isEmpty {
                                    Text("Nenhuma mensagem recente.")
                                        .font(.subheadline)
                                        .foregroundColor(.cinza)
                                        .padding(.vertical, 10)
                                } else {
                                    ForEach(profile.recentMessages) { msg in
                                        MessageSnapshotRow(msg: msg)
                                    }
                                }
                            }
                            .padding(.top, 10)
                        } label: {
                            HStack {
                                Image(systemName: "bubble.left.and.bubble.right")
                                Text("Mensagens Recentes")
                                    .font(.headline)
                                Spacer()
                            }
                            .foregroundColor(.secundaria)
                            .padding(.vertical, 8)
                        }
                        .accentColor(.secundaria)
                        .padding(.horizontal, 10)
                        .background(Color.branco.opacity(0.02))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    
                    if hasPendingChanges(profile: profile) {
                        HStack {
                            Spacer()
                            
                            Button {
                                Task {
                                    let finalScore = Int(draftScoreText) ?? profile.score ?? 0
                                    let finalStatus = draftStatus ?? profile.status
                                    let finalSegmentId = draftSegmentId == "" ? nil : (draftSegmentId ?? profile.segmentId)
                                    
                                    await viewModel.updateCrm(customerId: customerId, score: finalScore, status: finalStatus, segmentId: finalSegmentId)
                                    
                                    clearDrafts()
                                }
                            } label: {
                                Text("Salvar")
                                    .font(.subheadline).bold()
                                    .foregroundColor(.primaria)
                                    .padding(.horizontal, 40)
                                    .padding(.vertical, 10)
                                    .background(Color.secundaria)
                                    .cornerRadius(8)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut, value: hasPendingChanges(profile: profile))
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color.primaria.ignoresSafeArea())
        .onAppear {
            Task {
                await viewModel.fetchSegments()
                await viewModel.fetchProfile(customerId: customerId)
            }
        }
        .appPopup(data: $viewModel.popup) { closedPopup in
            if closedPopup.type == .success {
                clearDrafts()
            }
        }
        .alert("Editar Score", isPresented: $showingScoreAlert) {
            TextField("Digite o novo score", text: $draftScoreText)
                .keyboardType(.numberPad)
            
            Button("Confirmar") { }
            
            Button("Cancelar", role: .cancel) {
                draftScoreText = ""
            }
        } message: {
            Text("Insira a nova pontuação para este cliente.")
        }
    }
    
    // MARK: - Helper Methods
    private func hasPendingChanges(profile: Profile360Response) -> Bool {
        let scoreChanged = !draftScoreText.isEmpty && draftScoreText != "\(profile.score ?? 0)"
        let statusChanged = draftStatus != nil && draftStatus != profile.status
        
        let originalSegmentId = profile.segmentId ?? ""
        let draftSeg = draftSegmentId ?? originalSegmentId
        let segmentChanged = draftSeg != originalSegmentId
        
        return scoreChanged || statusChanged || segmentChanged
    }
    
    private func clearDrafts() {
        draftScoreText = ""
        draftStatus = nil
        draftSegmentId = nil
    }
}

// MARK: - IMPLEMENTAÇÃO DO FLOWLAYOUT
struct FlowLayout<T: Hashable, V: View>: View {
    let items: [T]
    let view: (T) -> V

    @State private var totalHeight = CGFloat.zero

    var body: some View {
        VStack {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in g: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(self.items, id: \.self) { item in
                self.view(item)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if item == self.items.last! {
                            width = 0
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: { d in
                        let result = height
                        if item == self.items.last! {
                            height = 0
                        }
                        return result
                    })
            }
        }
        .background(viewHeightReader($totalHeight))
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

// MARK: - Componentes Auxiliares
struct NoteRow: View {
    let note: NoteSnapshot
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: note.isTask ? "calendar.badge.exclamationmark" : "note.text")
                Text(note.isTask ? "Tarefa" : "Nota").font(.caption).bold()
                Spacer()
                if note.isTask {
                    Text(note.isResolved ? "Resolvido" : "Pendente")
                        .font(.caption2).padding(4)
                        .background(note.isResolved ? Color.green : Color.red)
                        .cornerRadius(4)
                }
            }
            .foregroundColor(.secundaria)
            
            Text(note.text)
                .font(.subheadline)
                .foregroundColor(.branco)
        }
        .padding()
        .background(Color.branco.opacity(0.05))
        .cornerRadius(10)
    }
}

struct MessageSnapshotRow: View {
    let msg: MessageSnapshot
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(msg.isFromOperator ? "Operador" : "Cliente")
                    .font(.caption2).foregroundColor(.cinza)
                Text(msg.text)
                    .font(.subheadline).lineLimit(1)
                    .foregroundColor(.branco)
            }
            Spacer()
            Text(msg.createdAt.formatted(date: .omitted, time: .shortened))
                .font(.caption2).foregroundColor(.cinza)
        }
        .padding()
        .background(Color.branco.opacity(0.05))
        .cornerRadius(10)
    }
}
