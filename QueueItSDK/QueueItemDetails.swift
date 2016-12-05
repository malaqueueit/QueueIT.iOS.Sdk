import Foundation

public class QueueItemDetails {
    var queueId: String
    var eventDetails: EventDTO
    
    public init(_ queueId: String, _ eventDetails: EventDTO) {
        self.queueId = queueId
        self.eventDetails = eventDetails
    }
}
