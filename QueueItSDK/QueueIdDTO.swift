import Foundation

class QueueIdDTO {
    var queueId: String
    var ttl: Int
    
    init(_ queueId: String, _ ttl: Int) {
        self.queueId = queueId
        self.ttl = ttl
    }
}
