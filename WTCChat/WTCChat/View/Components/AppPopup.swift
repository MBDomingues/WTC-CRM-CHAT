import SwiftUI
import UIKit

enum PopupType {
    case success
    case error
    
    var iconName: String {
        self == .success ? "checkmark.circle.fill" : "exclamationmark.circle.fill"
    }
    
    var iconColor: Color {
        self == .success ? .green : .secundaria
    }
    
    var buttonColor: Color {
        .azul
    }
    
    var buttonText: String {
        self == .success ? "Continuar" : "Entendido"
    }
}

struct PopupData: Equatable {
    let type: PopupType
    let title: String
    let message: String
}

struct AppPopupView: View {
    let data: PopupData
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: data.type.iconName)
                .font(.system(size: 50))
                .foregroundColor(data.type.iconColor)
            
            Text(data.title)
                .font(.title3.bold())
                .foregroundColor(.branco)
            
            Text(data.message)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.cinza)
                .padding(.horizontal)
            
            Button(action: onDismiss) {
                Text(data.type.buttonText)
                    .fontWeight(.bold)
                    .foregroundColor(.branco)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(data.type.buttonColor)
                    .cornerRadius(15)
            }
        }
        .padding(30)
        .background(Color.receivedBubble)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.cinza, lineWidth: 1)
        )
        .padding(.horizontal, 40)
    }
}

@MainActor func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

struct AppPopupModifier: ViewModifier {
    @Binding var popupData: PopupData?
    let onDismiss: ((PopupData) -> Void)?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if let data = popupData {
                Color.primaria.opacity(0.85)
                    .ignoresSafeArea()
                
                AppPopupView(data: data) {
                    popupData = nil
                    onDismiss?(data)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: popupData) { oldValue, newValue in
            if newValue != nil { hideKeyboard() }
        }
        .animation(.snappy(duration: 0.3), value: popupData)
    }
}

extension View {
    func appPopup(data: Binding<PopupData?>, onDismiss: ((PopupData) -> Void)? = nil) -> some View {
        self.modifier(AppPopupModifier(popupData: data, onDismiss: onDismiss))
    }
}
