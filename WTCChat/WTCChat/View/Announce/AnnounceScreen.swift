import SwiftUI
import PhotosUI

struct AnnounceScreen: View {
    @StateObject private var viewModel = AnnounceViewModel()
    @Binding var selectedTab: BottomNavBar.Tab
    @Binding var isSubScreenOpen: Bool
    @State private var isFormExpanded: Bool = false

    private var isFormValid: Bool {
        let hasTitle = !viewModel.titulo.trimmingCharacters(in: .whitespaces).isEmpty
        let hasLocation = !viewModel.local.trimmingCharacters(in: .whitespaces).isEmpty
        let hasDescription = !viewModel.descricao.trimmingCharacters(in: .whitespaces).isEmpty
        let hasImage = viewModel.selectedImage != nil
        
        return hasTitle && hasLocation && hasDescription && hasImage
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.primaria.ignoresSafeArea()
                let currentSelectedImage = viewModel.selectedImage
                
                ScrollView {
                    VStack(spacing: 0) {
                        Text("Anunciar em")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.secundaria)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Text("Massa")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.branco)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Spacer().frame(height: 32)
                        
                        PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                            if let image = currentSelectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "square.and.arrow.up")
                                        .font(.system(size: 56)).foregroundColor(.cinza)
                                    Text("Carregue a imagem ou poster\n(Obrigatório) *")
                                        .font(.system(size: 14)).foregroundColor(.cinza)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity).frame(height: 200)
                                .background(Color.fundoBotao.opacity(0.1))
                                .cornerRadius(16)
                                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.cinza.opacity(0.3), lineWidth: 1))
                            }
                        }

                        Spacer().frame(height: 24)

                        DisclosureGroup(
                            isExpanded: $isFormExpanded,
                            content: {
                                VStack(spacing: 12) {
                                    AnnounceTextField(label: "Título *", value: $viewModel.titulo, icon: "textformat", limit: 50)
                                    AnnounceDateField(label: "Data do Evento *", date: $viewModel.dataEvento)
                                    AnnounceTextField(label: "Local *", value: $viewModel.local, icon: "location", limit: 60)
                                    AnnounceTextField(label: "Descrição *", value: $viewModel.descricao, icon: "doc.text", minLines: 3, limit: 300)
                                }
                                .padding(.top, 16)
                            },
                            label: {
                                Text("Detalhes do anúncio")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.branco)
                            }
                        )
                        .accentColor(.secundaria)
                        
                        Spacer().frame(height: 32)
                        
                        Button {
                            isSubScreenOpen = true
                        } label: {
                            Text("Avançar")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isFormValid ? .branco : .cinza)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(isFormValid ? Color.azul : Color.fundoBotao.opacity(0.3))
                                .cornerRadius(27)
                        }
                        .disabled(!isFormValid)
                        .navigationDestination(isPresented: $isSubScreenOpen) {
                            SelectScreen(viewModel: viewModel, selectedTab: $selectedTab)
                        }
                        
                        Spacer().frame(height: 120)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct AnnounceTextField: View {
    let label: String
    @Binding var value: String
    let icon: String
    var minLines: Int = 1
    var limit: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(label, text: $value, axis: minLines > 1 ? .vertical : .horizontal)
                .foregroundColor(.branco)
                .lineLimit(minLines...minLines)
                .onChange(of: value) { oldValue, newValue in
                    if newValue.count > limit {
                        value = String(newValue.prefix(limit))
                    }
                }
            
            Text("\(value.count)/\(limit)")
                .font(.system(size: 10))
                .foregroundColor(value.count == limit ? .red : .cinza)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.fundoBotao.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.fundoBotao.opacity(0.1), lineWidth: 1)
        )
        .accentColor(.secundaria)
    }
}

struct AnnounceDateField: View {
    let label: String
    @Binding var date: Date

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(Color.cinza.opacity(0.8))
            
            Spacer()
            
            DatePicker("", selection: $date, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .labelsHidden()
                .environment(\.colorScheme, .dark)
                .accentColor(.secundaria)
        }
        .padding()
        .background(Color.fundoBotao.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.fundoBotao.opacity(0.1), lineWidth: 1)
        )
    }
}

struct AnnounceScreen_Previews: PreviewProvider {
    static var previews: some View {
        AnnounceScreen(selectedTab: .constant(.announce), isSubScreenOpen: .constant(false))
    }
}
