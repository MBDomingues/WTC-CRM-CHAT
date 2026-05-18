import SwiftUI
import Combine

struct LoginScreen: View {
    @StateObject private var viewModel = LoginViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.primaria
                .ignoresSafeArea()

            VStack(spacing: 0) {
                
                HStack {
                    headerLogin
                    Spacer()
                }
                .padding(.horizontal, 32)
                .padding(.top, 50)
                
                Spacer()

                VStack(spacing: 16) {
                    Text("Faça login na sua conta")
                        .font(.system(size: 20))
                        .foregroundColor(.branco)
                        .padding(.bottom, 4)

                    LoginTextField(placeholder: "WtcSaopaulo@gmail.com", text: $viewModel.email, icon: "envelope", isSecure: false, keyboardType: .emailAddress)
                    LoginTextField(placeholder: "Senha", text: $viewModel.password, icon: "lock", isSecure: true, keyboardType: .default)

                    Button {
                        Task { await viewModel.login() }
                    } label: {
                        Text("Login")
                            .font(.system(size: 18))
                            .foregroundColor(.branco)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(hex: "0D47A1"))
                            .cornerRadius(25)
                    }
                    .disabled(viewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.password.isEmpty || viewModel.isLoading)

                    Button("Esqueci minha Senha") {}
                        .foregroundColor(.cinza)
                    
                    footerLogin
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .onAppear {
                viewModel.onLoginSuccess = { response in
                    AuthManager.shared.login(content: response)
                }
            }
            .appPopup(data: $viewModel.popup)
        }
    }

    private var headerLogin: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Bem vindo")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.branco)
            
            Text("De volta")
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.secundaria)
                .padding(.top, -15)
        }
    }

    private var footerLogin: some View {
        VStack(spacing: 16) {
            Text("ou")
                .foregroundColor(.cinza)

            Button("Criar conta") {
                path.append(Route.signUp)
            }
            .foregroundColor(.branco)
            .fontWeight(.bold)
        }
    }
}

struct LoginTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    let isSecure: Bool
    let keyboardType: UIKeyboardType

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cinza)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
            }
        }
        .foregroundColor(.branco)
        .padding()
        .background(Color(hex: "37474F"))
        .cornerRadius(16)
        .accentColor(.secundaria)
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen(path: .constant(NavigationPath()))
    }
}
