import Foundation
import Combine

@MainActor
class Profile360ViewModel: ObservableObject {
    @Published var profile: Profile360Response?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var availableSegments: [Segment] = []
    @Published var popup: PopupData? = nil
    private let customerService = CustomerService()
    
    func fetchProfile(customerId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await customerService.getProfile360(id: customerId)
            self.profile = result
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func fetchSegments() async {
        do {
            self.availableSegments = try await SegmentService().getSegments()
        } catch {
            print("Erro ao buscar segmentos: \(error)")
        }
    }

    func updateCrm(customerId: String, score: Int?, status: String?, segmentId: String?) async {
            self.isLoading = true
            do {
                let success = try await CustomerService().updateCustomerCrm(customerId: customerId, score: score, status: status, segmentId: segmentId)
                
                if success {
                    await fetchProfile(customerId: customerId)
                    
                    self.popup = PopupData(type: .success, title: "Sucesso!", message: "Os dados do CRM foram atualizados.")
                } else {
                    self.popup = PopupData(type: .error, title: "Erro", message: "Não foi possível salvar os dados.")
                }
            } catch {
                self.popup = PopupData(type: .error, title: "Erro", message: "Falha de conexão com o servidor.")
            }
            self.isLoading = false
        }
}
