import SwiftUI
import PhotosUI

struct CreateGroupScreen: View {
    let initialSelectedMemberIds: Set<String>
    
    @Binding var chatDetailPath: NavigationPath
    @Binding var isNewChatModalPresented: Bool
    
    @StateObject private var viewModel = CreateGroupViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isShowingMemberSelection = false

    var body: some View {
        ZStack {
            Color.primaria.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        if let image = viewModel.selectedImage {
                            Image(uiImage: image)
                                .resizable().scaledToFill()
                                .frame(width: 140, height: 140).clipShape(Circle())
                                .overlay(Circle().stroke(Color.secundaria, lineWidth: 3))
                        } else {
                            ZStack {
                                Circle().fill(Color.branco.opacity(0.1))
                                    .frame(width: 140, height: 140)
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.fill").font(.title)
                                    Text("Adicionar foto").font(.caption)
                                }.foregroundColor(.cinza)
                            }
                        }
                    }
                    .onChange(of: selectedPhotoItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self),
                               let uiImage = UIImage(data: data) { viewModel.selectedImage = uiImage }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .trailing, spacing: 4) {
                            TextField("Nome do Grupo *", text: $viewModel.groupName)
                                .padding()
                                .background(Color.branco.opacity(0.05))
                                .cornerRadius(12)
                                .foregroundColor(.branco)
                                .onChange(of: viewModel.groupName) { oldValue, newValue in
                                    if newValue.count > 25 {
                                        viewModel.groupName = String(newValue.prefix(25))
                                    }
                                }
                            
                            Text("\(viewModel.groupName.count)/25")
                                .font(.caption2)
                                .foregroundColor(viewModel.groupName.trimmingCharacters(in: .whitespaces).isEmpty ? .red : .cinza)
                                .padding(.trailing, 4)
                        }
                        
                        TextField("Descrição (Opcional)", text: $viewModel.groupDescription)
                            .padding()
                            .background(Color.branco.opacity(0.05))
                            .cornerRadius(12)
                            .foregroundColor(.branco)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Participantes: \(viewModel.selectedMemberIds.count)")
                                .font(.subheadline)
                                .foregroundColor(.cinza)
                            
                            Spacer()
                            
                            Button {
                                isShowingMemberSelection = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.secundaria)
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                let selectedCustomers = viewModel.allCustomers.filter { viewModel.selectedMemberIds.contains($0.id) }
                                
                                ForEach(selectedCustomers) { customer in
                                    VStack {
                                        AsyncImage(url: URL(string: customer.imageUrl ?? "")) { phase in
                                            if let image = phase.image { image.resizable().scaledToFill() }
                                            else { Image(systemName: "person.circle.fill").foregroundColor(.cinza) }
                                        }
                                        .frame(width: 50, height: 50).clipShape(Circle())
                                        
                                        Text(customer.name.components(separatedBy: " ").first ?? "")
                                            .font(.caption2)
                                            .foregroundColor(.branco)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.branco.opacity(0.05))
                    .cornerRadius(12)
                    
                }
                .padding()
            }
        }
        .navigationTitle("Novo Grupo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        
                        let success = await viewModel.createGroup()
                        if success {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            
                            isNewChatModalPresented = false
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView().tint(.secundaria)
                    } else {
                        Text("Criar").fontWeight(.bold).foregroundColor(.secundaria)
                    }
                }
                .disabled(viewModel.groupName.trimmingCharacters(in: .whitespaces).isEmpty || viewModel.isLoading)
            }
        }
        .task {
            viewModel.selectedMemberIds = initialSelectedMemberIds
            await viewModel.fetchCustomers()
        }
        .appPopup(data: $viewModel.popup)
        
        .onChange(of: viewModel.popup) { oldValue, newValue in
            if newValue == nil && oldValue?.type == .success {
                chatDetailPath = NavigationPath()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isNewChatModalPresented = false
                }
            }
        }
        
        .sheet(isPresented: $isShowingMemberSelection) {
            EditGroupMembersSheet(
                allCustomers: viewModel.allCustomers,
                selectedIds: $viewModel.selectedMemberIds
            )
        }
    }
}

struct EditGroupMembersSheet: View {
    @Environment(\.dismiss) var dismiss
    let allCustomers: [Customer]
    @Binding var selectedIds: Set<String>
    
    @State private var searchText = ""
    
    var filteredCustomers: [Customer] {
        if searchText.isEmpty { return allCustomers }
        return allCustomers.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.cinza)
                    TextField("Buscar contatos...", text: $searchText)
                        .foregroundColor(.branco)
                        .autocorrectionDisabled()
                }
                .padding().background(Color.fundoBotao.opacity(0.1)).cornerRadius(12).padding()
                
                List(filteredCustomers) { customer in
                    Button {
                        if selectedIds.contains(customer.id) {
                            selectedIds.remove(customer.id)
                        } else {
                            selectedIds.insert(customer.id)
                        }
                    } label: {
                        HStack {
                            AsyncImage(url: URL(string: customer.imageUrl ?? "")) { phase in
                                if let image = phase.image { image.resizable().scaledToFill() }
                                else { Image(systemName: "person.circle.fill").foregroundColor(.cinza) }
                            }
                            .frame(width: 40, height: 40).clipShape(Circle())
                            
                            Text(customer.name).foregroundColor(.branco)
                            Spacer()
                            if selectedIds.contains(customer.id) {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.secundaria)
                            } else {
                                Image(systemName: "circle").foregroundColor(.cinza)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            .background(Color.primaria.ignoresSafeArea())
            .navigationTitle("Editar Participantes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluir") { dismiss() }
                        .foregroundColor(.secundaria)
                }
            }
        }
    }
}
