import Foundation
import Combine

@MainActor
class CustomerSelectionViewModel: ObservableObject {
    @Published var customers: [Customer] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    
    @Published var selectedCustomerIds: Set<String> = []

    private let customerService = CustomerService()
    private var searchTask: Task<Void, Never>? = nil

    func fetchCustomers() async {
        searchTask?.cancel()
        
        searchTask = Task {
            if !searchText.isEmpty {
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
            
            if Task.isCancelled { return }
            
            isLoading = true
            defer { isLoading = false }
            
            do {
                self.customers = try await customerService.fetchCustomers(query: searchText)
            } catch {
                print("Erro ao buscar clientes: \(error)")
                self.customers = []
            }
        }
    }
}
