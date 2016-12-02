import Foundation

class QueueItemDetails {
    var queueId: String
    var eventDetails: EventDTO
    
    init(_ queueId: String, _ eventDetails: EventDTO) {
        self.queueId = queueId
        self.eventDetails = eventDetails
    }
}
