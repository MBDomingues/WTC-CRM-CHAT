import Foundation

enum APIConfig {
    //Avaliar troca do host e porta!
    private static let host = "http://localhost"
    private static let port = "5157"
    
    static let baseUrl = URL(string: "http://\(host):\(port)/api")!
    
    static let signalRUrl = URL(string: "http://\(host):\(port)/chatHub")!
    
    enum Endpoints {
        static let login = "Auth/login"
        static let register = "Auth/register"
        static let updatePhoto = "Auth/update-photo"
        static let customerSearch = "Customer/searchClients"
        static let messages = "Messages"
        static let announceRecipients = "Announce/recipients"
        static let announcementsFeed = "Announce/feed"
    }
}
