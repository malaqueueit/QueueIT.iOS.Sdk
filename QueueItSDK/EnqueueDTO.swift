import Foundation

open class EnqueueDTO {
    var queueIdDto: QueueIdDTO?
    var eventDetails: EventDTO
    var redirectDto: RedirectDTO?
    
    init(_ queueIdDto: QueueIdDTO?, _ eventDetails: EventDTO, _ redirectDto: RedirectDTO?) {
        self.queueIdDto = queueIdDto
        self.eventDetails = eventDetails
        self.redirectDto = redirectDto
    }
}
