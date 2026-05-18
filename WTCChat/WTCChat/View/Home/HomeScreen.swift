import SwiftUI

struct HomeScreen: View {
    @State private var scale: CGFloat = 0.5
    @State private var alpha: Double = 0
    @Binding var path: NavigationPath

    var body: some View {
        ZStack {
            Color.primaria
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .scaleEffect(scale)
                    .opacity(alpha)

                Spacer()
                
                Image("World")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 450, height: 450)
                    .offset(x: -120)
                    .scaleEffect(scale)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                VStack(spacing: 20) {
                    Button(action: {
                        path.append(Route.signUp)
                    }) {
                        Text("Criar conta")
                            .font(.headline)
                            .foregroundColor(.branco)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.secundaria.opacity(0.8))
                            .cornerRadius(25)
                            .padding(.horizontal, 40)
                    }
                    
                    Button("Já tenho uma conta") {
                        path.append(Route.login)
                    }
                    .font(.subheadline)
                    .foregroundColor(.cinza)
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                scale = 1
                alpha = 1
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Preview
struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen(path: .constant(NavigationPath()))
    }
}
