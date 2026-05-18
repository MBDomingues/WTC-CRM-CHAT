import SwiftUI
import UIKit

struct BottomNavBar: View {
    @Binding var selectedTab: Tab
    var isAdmin: Bool = false
    
    @Namespace private var animation
    
    public enum Tab: String, CaseIterable {
        case events, chats, announce, segments, config
    }
    
    var body: some View {
        HStack(spacing: 6) {
            navItem(tab: .events, icon: "newspaper", selectedIcon: "newspaper.fill", label: "Mural")
            
            navItem(tab: .chats, icon: "message", selectedIcon: "message.fill", label: "Chats")
            
            if isAdmin {
                navItem(tab: .announce, icon: "megaphone", selectedIcon: "megaphone.fill", label: "Anunciar")
                
                navItem(tab: .segments, icon: "tag", selectedIcon: "tag.fill", label: "Segmentos")
            }
            
            navItem(tab: .config, icon: "gearshape", selectedIcon: "gearshape.fill", label: "Config")
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.regularMaterial)
        .environment(\.colorScheme, .dark)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(Color.white.opacity(0.15), lineWidth: 0.5)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
    
    @ViewBuilder
    private func navItem(
        tab: Tab,
        icon: String,
        selectedIcon: String,
        label: String,
        badge: Int? = nil
    ) -> some View {
        
        let isSelected = selectedTab == tab
        
        Button {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 2) {
                
                ZStack {
                    Image(systemName: isSelected ? selectedIcon : icon)
                        .font(.system(size: 20, weight: .medium))
                    
                    if let badge, badge > 0 {
                        Text("\(badge)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 10, y: -10)
                    }
                }
                
                Text(label)
                    .font(.system(size: 11, weight: isSelected ? .medium : .regular))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                            .matchedGeometryEffect(id: "TAB", in: animation)
                    }
                }
            )
        }
    }
}
