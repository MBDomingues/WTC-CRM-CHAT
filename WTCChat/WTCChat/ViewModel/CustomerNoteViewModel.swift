import Foundation
import Combine

@MainActor
class CustomerNotesViewModel: ObservableObject {
    @Published var notes: [CustomerNote] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service = CustomerNoteService()
    let customerId: String
    
    init(customerId: String) {
        self.customerId = customerId
    }
    
    func fetchNotes() async {
        isLoading = true
        errorMessage = nil
        do {
            self.notes = try await service.getNotes(customerId: customerId)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func createNote(text: String, isTask: Bool) async -> Bool {
        isLoading = true
        do {
            _ = try await service.createNote(customerId: customerId, text: text, isTask: isTask)
            await fetchNotes()
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func updateNote(noteId: String, text: String, isTask: Bool, isResolved: Bool) async -> Bool {
        isLoading = true
        do {
            _ = try await service.updateNote(noteId: noteId, text: text, isTask: isTask, isResolved: isResolved)
            await fetchNotes()
            return true
        } catch {
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func deleteNoteById(_ id: String) async {
        isLoading = true
        do {
            _ = try await service.deleteNote(noteId: id)
            if let index = notes.firstIndex(where: { $0.id == id }) {
                notes.remove(at: index)
            }
        } catch {
            self.errorMessage = "Erro ao deletar: \(error.localizedDescription)"
        }
        isLoading = false
    }
}
