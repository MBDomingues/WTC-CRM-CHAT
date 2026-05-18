import SwiftUI

struct EventoDetailScreen: View {
    let evento: AnnouncementItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                CachedAsyncImage(
                    urlString: evento.imageUrl,
                    cacheKey: evento.id,
                    placeholderSystemName: "photo.artframe"
                )
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(Color.cinza.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text(evento.title)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.branco)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.title2)
                                .foregroundColor(.secundaria)
                            
                            Text(evento.date)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.branco)
                        }
                        
                        if !evento.location.isEmpty {
                            Divider().background(Color.cinza.opacity(0.3))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.title2)
                                    .foregroundColor(.secundaria)
                                
                                Text(evento.location)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.branco)
                            }
                        }
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.fundoBotao.opacity(0.15))
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detalhes")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.branco)
                        
                        Text(evento.description)
                            .font(.system(size: 16))
                            .foregroundColor(.cinza)
                            .lineSpacing(6)
                    }
                }
                .padding(20)
            }
        }
        .background(Color.primaria.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.primaria, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
