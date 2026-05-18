import SwiftUI
import PhotosUI

struct ConfiguracoesScreen: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var selectedTab: BottomNavBar.Tab
    @State private var notificationsEnabled = true

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.primaria
                Text("Configurações")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.secundaria)
            }
            .frame(height: 60)

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            
                            CachedAsyncImage(
                                urlString: authManager.userImageUrl,
                                cacheKey: authManager.userImageUrl,
                                placeholderSystemName: "person.circle.fill"
                            )
                            .frame(width: 120, height: 120)
                            .background(Color.cinza.opacity(0.2))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                            
                            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 14))
                                    .padding(8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                            }
                        }
                        
                        if viewModel.isLoading {
                            ProgressView("Salvando...")
                                .font(.caption)
                                .foregroundColor(.cinza)
                        }
                    }
                    .padding(.vertical, 10)

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Detalhes da Conta")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.branco)
                        
                        ConfigField(label: "Nome", value: authManager.userName)
                    }

                    // Notificações
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Notificações")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.branco)

                        HStack {
                            Text("Deseja receber notificações do sistema?")
                                .font(.system(size: 14))
                                .foregroundColor(.cinza)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                            Toggle("", isOn: $notificationsEnabled)
                                .labelsHidden()
                                .tint(.blue)
                        }
                    }

                    Button(action: {
                        authManager.logout()
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sair da Conta")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .background(Color.primaria)
        .appPopup(data: $viewModel.popup)
                
        .onChange(of: viewModel.selectedItem) { oldValue, newValue in
            if let newValue {
                Task {
                    await viewModel.uploadPhoto(item: newValue, authManager: authManager)
                }
            }
        }
    }
}

struct ConfigField: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.cinza)
                .frame(width: 90, alignment: .leading)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16))
                .foregroundColor(.branco)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .padding(.horizontal, 16)
        .background(Color.fundoBotao.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ConfiguracoesScreen(selectedTab: .constant(.config))
        .environmentObject(AuthManager.shared)
}
