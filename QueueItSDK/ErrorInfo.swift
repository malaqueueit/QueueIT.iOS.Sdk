import Foundation

struct ErrorInfo {
    let id: String?
    let message: String
    
    init(_ id: String?, _ message: String) {
        self.id = id
        self.message = message
    }
}
