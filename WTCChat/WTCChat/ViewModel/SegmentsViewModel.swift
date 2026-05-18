import Foundation
import Combine

@MainActor
class SegmentsViewModel: ObservableObject {
    
    @Published var segments: [Segment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = SegmentService()
    
    func fetchSegments() async {
        isLoading = true
        errorMessage = nil
        do {
            self.segments = try await service.getSegments()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func createSegment(name: String, description: String) async -> Bool {
        isLoading = true
        do {
            _ = try await service.createSegment(name: name, description: description)
            await fetchSegments()
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func deleteSegmentById(_ id: String) async {
        isLoading = true
        do {
            try await service.deleteSegment(id: id)
            
            if let index = segments.firstIndex(where: { $0.id == id }) {
                segments.remove(at: index)
            }
        } catch {
            self.errorMessage = "Erro ao deletar: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func updateSegment(id: String, name: String, description: String) async -> Bool {
        isLoading = true
        do {
            try await service.updateSegment(id: id, name: name, description: description)
            await fetchSegments()
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
}
