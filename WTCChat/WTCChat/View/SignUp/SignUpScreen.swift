import SwiftUI
import Combine

struct SignUpScreen: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.primaria
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Criar Uma")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.branco)
                    Text("Conta")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.secundaria)
                        .padding(.top, -15)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 32)
                .padding(.bottom, 20)
                

                VStack(spacing: 16) {
                    Text("Crie sua conta e faça parte do time")
                        .font(.system(size: 17))
                        .foregroundColor(.branco)
                        .padding(.bottom, 8)


                    SignUpTextField(label: "Nome", text: $viewModel.name, icon: "person", keyboardType: .default)
                        .textInputAutocapitalization(.words)

                    SignUpTextField(label: "Email", text: $viewModel.email, icon: "envelope", keyboardType: .emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)

                    SignUpTextField(label: "CPF", text: $viewModel.documentId, icon: "doc.text", keyboardType: .numberPad)
                    SignUpTextField(label: "Senha", text: $viewModel.password, icon: "lock", isSecure: true)
                    SignUpTextField(label: "Confirmar senha", text: $viewModel.confirmPassword, icon: "checkmark.circle", isSecure: true)

                    Button {
                        Task { await viewModel.signUp() }
                    } label: {
                        Text("Criar")
                            .font(.system(size: 18))
                            .foregroundColor(.branco)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(viewModel.name.isEmpty || viewModel.isLoading ? Color.gray : Color(hex: "0D47A1"))
                            .cornerRadius(25)
                    }
                    .disabled(viewModel.name.isEmpty || viewModel.email.isEmpty || viewModel.documentId.isEmpty || viewModel.password.isEmpty || viewModel.confirmPassword.isEmpty || viewModel.isLoading)

                }
                .padding(.horizontal, 32)
                .padding(.bottom, 10)

                HStack(spacing: 4) {
                    Text("Já tem conta?")
                        .foregroundColor(.cinza)

                    Button("Logar") {
                        path.append(Route.login)
                    }
                    .foregroundColor(.branco)
                    .fontWeight(.bold)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.onSignUpSuccess = { response in
                AuthManager.shared.login(content: response)
            }
        }
        .appPopup(data: $viewModel.popup) { closedPopup in
        }
        .onChange(of: viewModel.documentId) { oldValue, newValue in
        }
    }
}

struct SignUpTextField: View {
    let label: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cinza)
            if isSecure {
                SecureField(label, text: $text)
            } else {
                TextField(label, text: $text)
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

// MARK: - Preview
struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen(path: .constant(NavigationPath()))
    }
}
