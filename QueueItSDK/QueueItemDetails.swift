import Foundation

public class QueueItemDetails {
    public var queueId: String
    public var eventDetails: EventDTO
    
    public init(_ queueId: String, _ eventDetails: EventDTO) {
        self.queueId = queueId
        self.eventDetails = eventDetails
    }
}
