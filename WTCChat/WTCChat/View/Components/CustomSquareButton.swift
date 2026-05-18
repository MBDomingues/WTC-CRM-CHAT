import SwiftUI

struct CustomSquareButton: View {
    let imageName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .frame(width: 50, height: 50)
                .background(Color.fundoBotao)
                .cornerRadius(12)
        }
    }
}
